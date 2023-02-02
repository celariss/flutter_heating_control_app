/// This file defines the Controller to gives access to the data model
/// It is used by all widget to get and set values in data
/// Each change in model is transfered to the heating control server, 
/// that processes the change and sends back the new model in case of success,
/// or the old one in case of failure (with error description)
/// 
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'common.dart';
import '../mqtt/mqtt_client.dart';
import 'package:event/event.dart';

import 'settings.dart';
import 'timetool.dart';

class ServerResponse {
  bool status = false;
  Map errorMap = {};
  String errorCode = '';
  String genericDesc = '';

  ServerResponse(Map jsonData) {
    status = ModelCtrl.get(jsonData, 'status', '') == 'success';
    errorMap = jsonData.containsKey('error') ? jsonData['error'] : {};
    errorCode = ModelCtrl.get(errorMap, 'id', '');
    genericDesc = ModelCtrl.get(errorMap, 'generic_desc', '');
  }
}

enum EMsgInfoType { info, warning, error }

enum EMsgInfoCode { other, mqttServerConnected, mqttServerDisconnected, controlServerUnavailable, mqttMessageError }

class MessageInfo {
  final EMsgInfoType type;
  final String text;
  final EMsgInfoCode code;
  MessageInfo(this.type, {required this.code, this.text = ''});
}

class Device {
  final String name;
  bool isAvailable = false;
  double actualSetpoint = -1.0;
  double? pendingSetpoint;
  bool pendingSetpointSent = false;
  //double ?setpointInCurrentSchedule;
  double currentTemperature = -1.0;
  Device(this.name);
}

class DeviceSetpoint {
  String deviceName;
  double setPoint;
  DeviceSetpoint(this.deviceName, this.setPoint);
}

class Timeslot {
  List<int> startTime;
  List<int> endTime;
  List<DeviceSetpoint> setPoints = [];
  Timeslot(this.startTime, this.endTime);
}

class ModelCtrl {
  // OK pour Web et io
  MQTTClient? _mqttClient;

  Timer? serverResponseWaitTimer;
  Timer? setSetpointTimer;
  Map _schedulerData = {};
  Map _savedSchedulerData = {};
  final Map<String, Device> _devices = {};
  List<Timeslot> _todayActiveSetpoints = [];
  var onSchedulesEvent = Event<Value<Map>>();
  var onDevicesEvent = Event<Value<Map<String, Device>>>();
  var onServerResponseEvent = Event<Value<ServerResponse>>();
  var onMessageEvent = Event<Value<MessageInfo>>();

  bool _isConnectedToServer = false;

  static final ModelCtrl _instance = ModelCtrl._internal();
  ModelCtrl._internal();
  factory ModelCtrl() {
    return _instance;
  }

  void connect() {
    //_mqttClient.logging(on:true);
    _mqttClient ??= MQTTClient(Settings().MQTT.brokerAddress, Settings().MQTT.port,
        ssl: Settings().MQTT.secure, user: Settings().MQTT.user, password: Settings().MQTT.password);
    _mqttClient!.onConnected = _onMqttConnected;
    _mqttClient!.onDisconnected = _onMqttDisconnected;
    _mqttClient!.onMessageString = _onMqttMessageString;
    if (_mqttClient!.isConnected() == false) {
      _mqttClient!.connect();
    }
  }

  void disconnect() {
    stopServerResponseWaitTimer();
    stopSetSetpointTimer();
    _mqttClient!.disconnect();
  }

  bool isConnectedToServer() {
    return _isConnectedToServer;
  }

  double? getActiveSetpoint(String deviceName, [List<int>? time]) {
    if (time == null) {
      DateTime now = DateTime.now();
      time = [now.hour, now.minute, now.second];
    }
    for (Timeslot timeslot in _todayActiveSetpoints) {
      if (TimeTool.compareTimes(timeslot.startTime, time) <= 0 && TimeTool.compareTimes(timeslot.endTime, time) > 0) {
        for (DeviceSetpoint dsp in timeslot.setPoints) {
          if (dsp.deviceName == deviceName) {
            return dsp.setPoint;
          }
        }
      }
    }
    return null;
  }

  List<Timeslot> getScheduleSetpoints(DateTime date, [Map? schedule]) {
    schedule ??= getActiveSchedule();
    List<Timeslot> result = [];
    if (schedule.isNotEmpty) {
      for (Map item in schedule['schedule_items']) {
        Map? tss = getTimeslotSetForDate(item, date);
        if (tss != null) {
          List devices = item['devices'];
          List<Timeslot> timeslots = [];
          List<int> startTime = [0, 0, 0];
          for (Map ts in tss['timeslots']) {
            startTime = TimeTool.parseTimeStr(ts['start_time']) ?? startTime;
            if (timeslots.isNotEmpty) {
              timeslots[timeslots.length - 1].endTime = startTime;
            }
            // Get the timeslot color from the temperature set name
            String tempSetName = ts['temperature_set'];
            Map tempSet = ModelCtrl().buildTemperatureSet(tempSetName, schedule['alias']);
            if (tempSet.isNotEmpty) {
              Timeslot timeslot = Timeslot(startTime, startTime);
              for (Map devSetpoint in tempSet['devices']) {
                if (devices.contains(devSetpoint['device_name'])) {
                  timeslot.setPoints.add(DeviceSetpoint(devSetpoint['device_name'], devSetpoint['setpoint']));
                }
              }
              //timeslot.setPoints
              timeslots.add(timeslot);
            }
          }
          if (timeslots.isNotEmpty) {
            timeslots[timeslots.length - 1].endTime = [24, 0, 0];
          }
          // Now let's merge the timeslots for these devices with global result
          result = mergeTimeslots(timeslots, result);
        }
      }
    }
    return result;
  }

  static List<Timeslot> mergeTimeslots(List<Timeslot> timeslots1, List<Timeslot> timeslots2) {
    List<List<int>> times = [];
    for (Timeslot ts in timeslots1) {
      times.add(ts.startTime);
    }
    for (Timeslot ts in timeslots2) {
      if (TimeTool.findTime(times, ts.startTime) < 0) {
        times.add(ts.startTime);
      }
    }
    times = times.toSet().toList();
    times.sort((a, b) => TimeTool.compareTimes(a, b));

    List<Timeslot> result = [];
    for (int idx = 0; idx < times.length; idx++) {
      List<int> startTime = times[idx];
      List<int> endTime = (idx + 1 < times.length) ? times[idx + 1] : [24, 0, 0];
      List<int> time = [startTime[0], startTime[1], startTime[2] + 1];
      Timeslot? ts1 = findTimeslot(timeslots1, time);
      Timeslot? ts2 = findTimeslot(timeslots2, time);
      Timeslot ts = Timeslot(startTime, endTime);
      if (ts1 != null) {
        ts.setPoints.addAll(ts1.setPoints);
      }
      if (ts2 != null) {
        ts.setPoints.addAll(ts2.setPoints);
      }
      result.add(ts);
    }
    return result;
  }

  static Timeslot? findTimeslot(List<Timeslot> timeslots, List<int> time) {
    for (Timeslot ts in timeslots) {
      if (TimeTool.compareTimes(ts.startTime, time) < 0 && TimeTool.compareTimes(ts.endTime, time) > 0) {
        return ts;
      }
    }
    return null;
  }

  bool deleteTemperatureSet(String tempSetName, [String scheduleName = '']) {
    List tempSetsData = getTemperatureSets(scheduleName);
    for (Map tempSetData in tempSetsData) {
      if (tempSetData.containsKey('alias') && tempSetData['alias'] == tempSetName) {
        tempSetsData.remove(tempSetData);
        onTemperatureSetsChanged(scheduleName);
        return true;
      }
    }
    return false;
  }

  Map? getScheduleItem(String scheduleName, int scheduleItemIdx) {
    Map schedule = getSchedule(scheduleName);
    if (schedule.isNotEmpty && schedule['schedule_items'].length > scheduleItemIdx) {
      Map scheduleItem = schedule['schedule_items'][scheduleItemIdx];
      return scheduleItem;
    }
    return null;
  }

  Map? getTimeslotSet(String scheduleName, int scheduleItemIdx, int timeslotSetIdx) {
    Map? scheduleItem = getScheduleItem(scheduleName, scheduleItemIdx);
    if (scheduleItem != null && scheduleItem['timeslots_sets'].length > timeslotSetIdx) {
      return scheduleItem['timeslots_sets'][timeslotSetIdx];
    }
    return null;
  }

  Map? getTimeslotSetForDate(Map scheduleItem, DateTime date) {
    for (Map tss in scheduleItem['timeslots_sets']) {
      if ((tss['dates'] as List).contains(date.weekday.toString())) {
        return tss;
      }
    }
    return null;
  }

  void setDeviceSetpoint(String deviceName, double value) {
    if (_devices.containsKey(deviceName)) {
      value = (value * 10).floor() / 10;
      _devices[deviceName]!.pendingSetpoint = value;
      _devices[deviceName]!.pendingSetpointSent = false;
      startSetSetpointTimer();
    }
  }

  void setTimeslotSet(String scheduleName, int scheduleItemIdx, int timeslotSetIdx, Map timeslotSetData) {
    Map? scheduleItem = getScheduleItem(scheduleName, scheduleItemIdx);
    if (scheduleItem != null && scheduleItem['timeslots_sets'].length > timeslotSetIdx) {
      scheduleItem['timeslots_sets'][timeslotSetIdx] = timeslotSetData;
      onScheduleChanged(scheduleName);
    }
  }

  void createTemperatureSet(int colorValue, String tempSetName, {String scheduleName = '', Map? newTempSetData}) {
    Map tempSetData = {'alias': tempSetName, 'devices': []};
    if (newTempSetData != null) {
      tempSetData = newTempSetData;
    }
    ModelCtrl.setGUIParamHex(tempSetData, 'iconColor', colorValue);
    getTemperatureSets(scheduleName).add(tempSetData);
    onTemperatureSetsChanged(scheduleName);
  }

  void createSchedule(String scheduleName, [Map? scheduleContent]) {
    if (_devices.isNotEmpty &&
        scheduleName.isNotEmpty &&
        _schedulerData.isNotEmpty &&
        _schedulerData.containsKey('temperature_sets') &&
        (_schedulerData['temperature_sets'].length > 0)) {
      String deviceName = _devices.keys.first;
      String tempSetName = _schedulerData['temperature_sets'][0]['alias'];
      Map scheduleData = scheduleContent ??
          {
            'schedule_items': [
              {
                'devices': [deviceName],
                'timeslots_sets': [
                  {
                    'dates': ['1', '2', '3', '4', '5', '6', '7'],
                    'timeslots': [
                      {'start_time': '00:00:00', 'temperature_set': tempSetName}
                    ]
                  }
                ]
              }
            ]
          };

      scheduleData['alias'] = createAvailableScheduleName(scheduleName);
      _onScheduleChanged(scheduleData);
    }
  }

  String createAvailableScheduleName(String desiredAlias) {
    String name = desiredAlias;
    int count = 0;
    while (getSchedule(name).isNotEmpty) {
      count++;
      name = '$desiredAlias ($count)';
    }
    return name;
  }

  String createAvailableTempSetName(String desiredAlias) {
    String name = desiredAlias;
    int count = 0;
    while (getTemperatureSet(name).isNotEmpty) {
      count++;
      name = '$desiredAlias ($count)';
    }
    return name;
  }

  Map getActiveSchedule() {
    if (_schedulerData.containsKey('active_schedule')) {
      String? activeScheduleName = _schedulerData['active_schedule'];
      if (activeScheduleName != null) {
        return getSchedule(activeScheduleName);
      }
    }
    return {};
  }

  void setActiveSchedule(String scheduleName) {
    Map message = {};
    message['schedule_name'] = scheduleName;
    _mqttPublishMap(Settings().MQTT.setActiveScheduleTopic, message);
  }

  void deleteSchedule(String scheduleName) {
    Map message = {};
    message['schedule_name'] = scheduleName;
    _mqttPublishMap(Settings().MQTT.deleteScheduleTopic, message);
  }

  void deleteScheduleItem(String scheduleName, int scheduleItemIdx) {
    Map schedule = getSchedule(scheduleName);
    if (schedule.isNotEmpty && schedule['schedule_items'].length > scheduleItemIdx) {
      schedule['schedule_items'].removeAt(scheduleItemIdx);
      _onScheduleChanged(schedule);
    }
  }

  void deleteScheduleItemTS(String scheduleName, int scheduleItemIdx, int timeslotSetIdx) {
    Map schedule = getSchedule(scheduleName);
    if (schedule.isNotEmpty && schedule['schedule_items'].length > scheduleItemIdx) {
      Map scheduleItem = schedule['schedule_items'][scheduleItemIdx];
      if (scheduleItem['timeslots_sets'].length > timeslotSetIdx) {
        scheduleItem['timeslots_sets'].removeAt(timeslotSetIdx);
        _onScheduleChanged(schedule);
      }
    }
  }

  void createScheduleItem(String scheduleName, [Map? scheduleItemData]) {
    Map schedule = getSchedule(scheduleName);
    if (_devices.isNotEmpty &&
        schedule.isNotEmpty &&
        _schedulerData.containsKey('temperature_sets') &&
        (_schedulerData['temperature_sets'].length > 0)) {
      String deviceName = _devices.keys.first;
      String tempSetName = _schedulerData['temperature_sets'][0]['alias'];
      Map scheduleItem = scheduleItemData ??
          {
            'devices': [deviceName],
            'timeslots_sets': [
              {
                'dates': ['1', '2', '3', '4', '5', '6', '7'],
                'timeslots': [
                  {'start_time': '00:00:00', 'temperature_set': tempSetName}
                ]
              }
            ]
          };
      Map scheduleClone = {...schedule};
      scheduleClone['schedule_items'].add(scheduleItem);
      _onScheduleChanged(scheduleClone);
    }
  }

  createTimeSlotSet(String scheduleName, int scheduleItemIdx, {Map? data}) {
    Map schedule = getSchedule(scheduleName);
    if (schedule.isNotEmpty &&
        (schedule['schedule_items'].length > scheduleItemIdx) &&
        _schedulerData.containsKey('temperature_sets') &&
        (_schedulerData['temperature_sets'].length > 0)) {
      Map scheduleItem = schedule['schedule_items'][scheduleItemIdx];
      String tempSetName = _schedulerData['temperature_sets'][0]['alias'];
      scheduleItem['timeslots_sets'].add(data ??
          {
            'dates': [],
            'timeslots': [
              {'start_time': '00:00:00', 'temperature_set': tempSetName}
            ]
          });
      _onScheduleChanged(schedule);
    }
  }

  /// This method ensures that all weekdays are assigned to one and only one timeslot set
  void assignWeekDay(String scheduleName, int scheduleItemIdx, int timeslotSetIdx, String weekDay) {
    _unassignWeekDay(scheduleName, scheduleItemIdx, weekDay);
    Map schedule = getSchedule(scheduleName);
    if (schedule.isNotEmpty && schedule['schedule_items'].length > scheduleItemIdx) {
      Map scheduleItem = schedule['schedule_items'][scheduleItemIdx];
      if (scheduleItem['timeslots_sets'].length > timeslotSetIdx) {
        Map timeSlotSet = scheduleItem['timeslots_sets'][timeslotSetIdx];
        if (!timeSlotSet['dates'].contains(weekDay)) {
          timeSlotSet['dates'].add(weekDay);
          _onScheduleChanged(schedule);
        }
      }
    }
  }

  void onScheduleNameChanged(String scheduleName, String newName) {
    if (scheduleName != newName) {
      Map message = {};
      message['old_name'] = scheduleName;
      message['new_name'] = newName;
      _mqttPublishMap(Settings().MQTT.setScheduleNameTopic, message);
    }
  }

  void onTemperatureSetNameChanged(String scheduleName, [String tempSetName = '', String newTempSetName = '']) {
    if (tempSetName != newTempSetName) {
      Map message = {};
      message['old_name'] = tempSetName;
      message['new_name'] = newTempSetName;
      message['schedule_name'] = scheduleName;
      _mqttPublishMap(Settings().MQTT.setTemperatureSetNameTopic, message);
    }
  }

  void onTemperatureSetsChanged([String scheduleName = '']) {
    List tempSetsData = getTemperatureSets(scheduleName);
    Map message = {};
    message['temperature_sets'] = tempSetsData;
    message['schedule_name'] = scheduleName;
    _mqttPublishMap(Settings().MQTT.setTemperatureSetsTopic, message);
  }

  void onSchedulesReorder() {
    List message = getSchedules().map((e) => e['alias']).toList();
    _mqttPublishString(Settings().MQTT.setSchedulesOrder, jsonEncode(message));
  }

  void onScheduleChanged(String scheduleName) {
    _onScheduleChanged(getSchedule(scheduleName));
  }

  Map getSchedule(String scheduleName) {
    if (_schedulerData.isNotEmpty) {
      for (Map schedule in _schedulerData['schedules']) {
        if (schedule['alias'] == scheduleName) {
          return schedule;
        }
      }
    }
    return {};
  }

  void swapTemperatureSets(int index1, int index2, [String scheduleName = '']) {
    List tempSets = getTemperatureSets(scheduleName);
    if (tempSets.length > (max(index1, index2))) {
      if (kDebugMode) {
        print("moved tempSet '${tempSets[index1]['alias']}' from index $index1 to index $index2");
      }
      Map item = tempSets.removeAt(index1);
      tempSets.insert(index2, item);
      onTemperatureSetsChanged(scheduleName);
    }
  }

  void swapSchedules(int index1, int index2) {
    List schedules = getSchedules();
    if (schedules.length > (max(index1, index2))) {
      if (kDebugMode) {
        print("moved schedule '${schedules[index1]['alias']}' from index $index1 to index $index2");
      }
      Map item = schedules.removeAt(index1);
      schedules.insert(index2, item);
      onSchedulesReorder();
    }
  }

  void swapScheduleItems(String scheduleName, int index1, int index2) {
    Map schedule = ModelCtrl().getSchedule(scheduleName);
    if (schedule.isNotEmpty) {
      List items = schedule['schedule_items'];
      if (index1 >= 0 && index2 >= 0 && items.length > index1 && items.length > index2) {
        Map tmp = items[index1];
        items[index1] = items[index2];
        items[index2] = tmp;
        ModelCtrl().onScheduleChanged(scheduleName);
      }
    }
  }

  List getSchedules() {
    if (_schedulerData.isNotEmpty) {
      return _schedulerData['schedules'];
    }
    return [];
  }

  Map<String, Device> getDevices() {
    return _devices;
  }

  /// Get the temperature sets for given [scheduleName]
  ///
  /// If [scheduleName] is an empty string, the global sets list is returned
  /// if no sets are found, the method returns an empty List
  List getTemperatureSets([String scheduleName = '']) {
    Map data;
    if (scheduleName.isEmpty) {
      data = _schedulerData;
    } else {
      data = getSchedule(scheduleName);
    }
    if (data.containsKey('temperature_sets')) {
      return data['temperature_sets'];
    }
    return [];
  }

  /// Get the temperature set [tempSetName] in given [scheduleName]
  ///
  /// If [scheduleName] is an empty string, a global set is returned
  /// if no set is found, the method returns an empty Map
  Map getTemperatureSet(String tempSetName, [String scheduleName = '']) {
    List tempSetsData = getTemperatureSets(scheduleName);
    for (Map tempSetData in tempSetsData) {
      if (tempSetData.containsKey('alias') && tempSetData['alias'] == tempSetName) {
        return tempSetData;
      }
    }
    return {};
  }

  /// Build the temperature set data map that reflects the actual content of [tempSetName] set in given [scheduleName] schedule
  ///
  /// It takes into account the inheritance to merge elements from schedule and global sets
  /// if no set is found for given [tempSetName] or if there is an missing set in the inheritance tree, then the method returns an empty Map
  /// TBD : avoid search loop
  Map buildTemperatureSet(String tempSetName, String scheduleName) {
    List resultList = [];
    if (_buildTemperatureSetRecurse(tempSetName, scheduleName, resultList)) {
      Map result = resultList[0];
      resultList.removeAt(0);
      for (Map tempSet in resultList) {
        for (Map device in tempSet['devices']) {
          if (!_isDeviceInTemperatureSet(result, device['device_name'])) {
            result['devices'].add(device);
          }
        }
      }
      return result;
    }
    return {};
  }

  ///////////////////////////////////////////////////////////////////
  /////                STATIC METHODS                          //////
  //////////////////////////////////////////////////////////////////////
  static String get(Map map, String paramName, String defaultValue) {
    if (map.containsKey(paramName)) {
      return map[paramName];
    }
    return defaultValue;
  }

  static int getInt(Map map, String paramName, int defaultValue) {
    if (map.containsKey(paramName)) {
      return map[paramName];
    }
    return defaultValue;
  }

  static String getGUIParam(Map dico, String paramName, String defaultValue) {
    if (dico.containsKey('GUI')) {
      if (dico['GUI'].containsKey(paramName)) {
        return dico['GUI'][paramName];
      }
    }
    return defaultValue;
  }

  static int getGUIParamHex(Map dico, String paramName, int defaultValue) {
    String strValue = getGUIParam(dico, paramName, '');
    if (strValue != '') {
      try {
        return int.parse(strValue.split('0x')[1], radix: 16);
      } on FormatException {
        //
      } catch (e) {
        //
      }
    }
    return defaultValue;
  }

  void cloneSchedule(String scheduleName) {
    Map schedule = getSchedule(scheduleName);
    if (schedule.isNotEmpty) {
      createSchedule(scheduleName, cloneMap(schedule));
    }
  }

  void cloneScheduleItem(String scheduleName, int scheduleItemIdx, String targetScheduleName) {
    Map schedule = getSchedule(scheduleName);
    Map targetSchedule = getSchedule(targetScheduleName);
    if (schedule.isNotEmpty && targetSchedule.isNotEmpty && schedule['schedule_items'].length > scheduleItemIdx) {
      createScheduleItem(targetScheduleName, cloneMap(schedule['schedule_items'][scheduleItemIdx]));
    }
  }

  static void setGUIParamHex(Map dico, String paramName, int value) {
    if (dico.containsKey('GUI') == false) {
      Map m = {};
      m[paramName] = '0x${value.toRadixString(16)}';
      dico['GUI'] = m;
    } else {
      dico['GUI'][paramName] = '0x${value.toRadixString(16)}';
    }
  }

  static Map cloneMap(Map data) {
    return jsonDecode(jsonEncode(data));
  }

  ///////////////////////////////////////////////////////////////////
  /////                PRIVATE METHODS                          //////
  //////////////////////////////////////////////////////////////////////
  bool _mqttPublishMap(String topic, Map data) {
    return _mqttPublishString(topic, jsonEncode(data));
  }

  bool _mqttPublishString(String topic, String data) {
    if (_isConnectedToServer && _mqttClient!.isConnected() == false) {
      _isConnectedToServer = false;
      onMessageEvent.broadcast(Value(MessageInfo(EMsgInfoType.warning, code: EMsgInfoCode.mqttServerDisconnected)));
    }
    if (_isConnectedToServer && _mqttClient!.publish(topic, data)) {
      startServerResponseWaitTimer();
      return true;
    }
    return false;
  }

  void _onMqttConnected() {
    if (kDebugMode) {
      print('ModelCtrl: MQTT CONNECTED');
    }
    if (_isConnectedToServer == false) {
      _isConnectedToServer = true;
      onMessageEvent.broadcast(Value(MessageInfo(EMsgInfoType.info, code: EMsgInfoCode.mqttServerConnected)));
    }
    _mqttClient!.subscribe(Settings().MQTT.onSchedulerTopic);
    _mqttClient!.subscribe(Settings().MQTT.onDevicesTopic);
    _mqttClient!.subscribe(Settings().MQTT.onResponseTopic);
    _mqttClient!.subscribe(Settings().MQTT.onDeviceChangeTopic);
  }

  void _onMqttDisconnected(bool unexpected) {
    if (kDebugMode) {
      print('ModelCtrl: MQTT DISCONNECTED');
    }
    stopServerResponseWaitTimer();
    stopSetSetpointTimer();
    _mqttClient!.unsubscribe(Settings().MQTT.onSchedulerTopic);
    _mqttClient!.unsubscribe(Settings().MQTT.onDevicesTopic);
    _mqttClient!.unsubscribe(Settings().MQTT.onResponseTopic);
    _mqttClient!.unsubscribe(Settings().MQTT.onDeviceChangeTopic);
    if (_isConnectedToServer = true) {
      _isConnectedToServer = false;
      onMessageEvent.broadcast(Value(MessageInfo(EMsgInfoType.warning, code: EMsgInfoCode.mqttServerDisconnected)));
      _onDevicesNotAvailable();
    }
    if (unexpected) {
      connect();
    }
  }

  void _onMqttMessageString(String topic, String payload) {
    if (kDebugMode) {
      print('ModelCtrl: MQTT Message notification:: topic is <$topic}>, payload is <-- $payload -->');
    }
    try {
      if (topic == Settings().MQTT.onDevicesTopic) {
        List devicesData = jsonDecode(payload);
        _devices.clear();
        for (Map devData in devicesData) {
          _devices[devData['name']] = Device(devData['name']);
        }
        onDevicesEvent.broadcast(Value(_devices));
      } else if (topic == Settings().MQTT.onSchedulerTopic) {
        _schedulerData = jsonDecode(payload);
        _savedSchedulerData = jsonDecode(payload);
        _todayActiveSetpoints = getScheduleSetpoints(DateTime.now());
        onSchedulesEvent.broadcast(Value(_schedulerData));
      } else if (topic == Settings().MQTT.onResponseTopic) {
        Map responseData = jsonDecode(payload);
        _onServerResponse(responseData);
      } else if (topic.startsWith(Settings().MQTT.onDeviceChangeTopic.replaceFirst('#', ''))) {
        _onDeviceChange(topic, payload);
      }
    } catch (e) {
      print('ModelCtrl: Error in MQTT message format : $e');
      onMessageEvent.broadcast(Value(MessageInfo(EMsgInfoType.error, code: EMsgInfoCode.mqttMessageError)));
    }
  }

  void _onServerResponse(Map responseData) {
    stopServerResponseWaitTimer();
    bool success = responseData.containsKey('status') ? responseData['status'] == 'success' : false;
    if (!success) {
      // Error on previous command => we rollback last changes
      _schedulerData = cloneMap(_savedSchedulerData);
      onSchedulesEvent.broadcast(Value(_schedulerData));
    } else {
      _savedSchedulerData = cloneMap(_schedulerData);
    }
    onServerResponseEvent.broadcast(Value(ServerResponse(responseData)));
  }

  void _onScheduleChanged(Map scheduleData) {
    //onSchedulesEvent.broadcast(Value(schedulerData));
    if (scheduleData.isNotEmpty) {
      _mqttPublishMap(Settings().MQTT.setScheduleTopic, scheduleData);
    }
  }

  void _onDeviceChange(String topic, String data) {
    List<String> list = topic.split('/');
    if (list.length > 1) {
      String paramName = list[list.length - 1];
      String deviceName = list[list.length - 2];

      if (_devices.containsKey(deviceName)) {
        switch (paramName) {
          case 'on_setpoint':
            double? doubleValue = str2Double(data);
            if (doubleValue == null) {
              return;
            }
            _devices[deviceName]!.actualSetpoint = doubleValue;
            //if (_devices[deviceName]!.pendingSetpoint == value) {
            _devices[deviceName]!.pendingSetpoint = null;
            //}
            break;

          case 'on_current_temp':
            double? doubleValue = str2Double(data);
            if (doubleValue == null) {
              return;
            }
            _devices[deviceName]!.currentTemperature = doubleValue;
            break;

          case 'on_state':
            _devices[deviceName]!.isAvailable = (data == 'true' ? true : false);
            break;

          default:
            return;
        }
      }
      onDevicesEvent.broadcast(Value(_devices));
    }
  }

  void startServerResponseWaitTimer() {
    if (serverResponseWaitTimer != null) {
      stopServerResponseWaitTimer();
    }
    serverResponseWaitTimer = Timer(const Duration(seconds: 10), _onServerResponseTimeOut);
  }

  void stopServerResponseWaitTimer() {
    if (serverResponseWaitTimer != null) {
      if (serverResponseWaitTimer!.isActive) {
        serverResponseWaitTimer!.cancel();
      }
      serverResponseWaitTimer = null;
    }
  }

  void _onServerResponseTimeOut() {
    serverResponseWaitTimer = null;
    // Error on previous command => we rollback last changes
    _schedulerData = cloneMap(_savedSchedulerData);
    onSchedulesEvent.broadcast(Value(_schedulerData));
    // We notify the problem with the heating control server
    onMessageEvent.broadcast(Value(MessageInfo(EMsgInfoType.error, code: EMsgInfoCode.controlServerUnavailable)));
    _onDevicesNotAvailable();
  }

  void startSetSetpointTimer() {
    if (setSetpointTimer != null) {
      stopSetSetpointTimer();
    }
    setSetpointTimer = Timer(const Duration(seconds: 5), _onSetSetpointTimeOut);
  }

  void stopSetSetpointTimer() {
    if (setSetpointTimer != null) {
      if (setSetpointTimer!.isActive) {
        setSetpointTimer!.cancel();
      }
      setSetpointTimer = null;
    }
  }

  void _onSetSetpointTimeOut() {
    if (kDebugMode) {
      print('ModelCtrl::_onSetSetpointTimeOut');
    }
    setSetpointTimer = null;
    for (Device device in _devices.values) {
      if (device.pendingSetpointSent == false && device.pendingSetpoint != null) {
        if (kDebugMode) {
          print('ModelCtrl::_onSetSetpointTimeOut -> Send setpoint for device ${device.name}');
        }
        Map data = {'device_name': device.name, 'setpoint': device.pendingSetpoint};
        if (_mqttPublishMap(Settings().MQTT.setDeviceSetpoint, data)) {
          device.pendingSetpointSent = true;
        }
      }
    }
  }

  /// Unassign given weekday without doing anything else.
  /// The caller must ensure that this weekday will be reassign
  bool _unassignWeekDay(String scheduleName, int scheduleItemIdx, String weekDay) {
    Map schedule = getSchedule(scheduleName);
    if (schedule.isNotEmpty && schedule['schedule_items'].length > scheduleItemIdx) {
      Map scheduleItem = schedule['schedule_items'][scheduleItemIdx];
      for (Map timeSlotSet in scheduleItem['timeslots_sets']) {
        if (timeSlotSet['dates'].contains(weekDay)) {
          timeSlotSet['dates'].remove(weekDay);
          return true;
        }
      }
    }
    return false;
  }

  void _onDevicesNotAvailable() {
    for (Device device in _devices.values) {
      device.isAvailable = false;
    }
    onDevicesEvent.broadcast(Value(_devices));
  }

  bool _isDeviceInTemperatureSet(Map tempSet, String deviceName) {
    for (Map device in tempSet['devices']) {
      if (device['device_name'] == deviceName) {
        return true;
      }
    }
    return false;
  }

  bool _buildTemperatureSetRecurse(String tempSetName, String scheduleName, List currentResult) {
    Map tempSet = getTemperatureSet(tempSetName, scheduleName);
    if (tempSet.isEmpty && scheduleName.isNotEmpty) {
      // May be the parent is a global set
      tempSet = getTemperatureSet(tempSetName, '');
      scheduleName = '';
    }

    if (tempSet.isNotEmpty) {
      currentResult.add(tempSet);
      // let's see if the temperature set inherits from other one
      if (tempSet.containsKey('inherits') && tempSet['inherits'] != null) {
        return _buildTemperatureSetRecurse(tempSet['inherits'], scheduleName, currentResult);
      }
      return true;
    }

    return false;
  }
}

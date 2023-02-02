/// Defines the MQTT part of app settings
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
/// 

class MQTTSettings {
  MQTTSettings();
  MQTTSettings.fromMap(Map config)
      : setScheduleTopic = config['setScheduleTopic'],
        setTemperatureSetsTopic = config['setTemperatureSetsTopic'],
        setTemperatureSetNameTopic = config['setTemperatureSetNameTopic'],
        setScheduleNameTopic = config['setScheduleNameTopic'],
        setActiveScheduleTopic = config['setActiveScheduleTopic'],
        setSchedulesOrder = config['setSchedulesOrder'],
        deleteScheduleTopic = config['deleteScheduleTopic'],
        setDeviceSetpoint = config['setDeviceSetpoint'],
        onResponseTopic = config['onResponseTopic'],
        onSchedulerTopic = config['onSchedulerTopic'],
        onDevicesTopic = config['onDevicesTopic'],
        onDeviceChangeTopic = config['onDeviceChangeTopic'],
        brokerAddress = config['brokerAddress'],
        port = config['port'],
        secure = config['secure'],
        user = config['user'],
        password = config['password'];

  String setScheduleTopic = '';
  String setTemperatureSetsTopic = '';
  String setTemperatureSetNameTopic = '';
  String setScheduleNameTopic = '';
  String setActiveScheduleTopic = '';
  String setSchedulesOrder = '';
  String deleteScheduleTopic = '';
  String setDeviceSetpoint = '';
  String onResponseTopic = '';
  String onSchedulerTopic = '';
  String onDevicesTopic = '';
  String onDeviceChangeTopic = '';

  int port = 0;
  bool secure = false;
  String brokerAddress = '';
  String user = '';
  String password = '';
}

import 'package:flutter/material.dart';
import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import '../../common/timetool.dart';
import '../../utils/localizations.dart';
import '../schedule/timeslots.dart';
import '../temperatureset/temperaturesets_utils.dart';

class TimeSlotSetEditor extends StatefulWidget {
  final String scheduleName;
  final int scheduleItemIdx;
  final int timeslotSetIdx;
  final String tsKey;

  const TimeSlotSetEditor(
      {super.key, required this.scheduleName, required this.scheduleItemIdx, required this.timeslotSetIdx, required this.tsKey});

  @override
  State<TimeSlotSetEditor> createState() => _TimeSlotSetEditor();
}

class _TimeSlotSetEditor extends State<TimeSlotSetEditor> {
  Map timeslotSetData = {};
  bool pullData = true;

  _TimeSlotSetEditor();

  @override
  Widget build(BuildContext context) {
    // If pullData==false, the build cause is internal => local data must not be discarded
    // IF pullData==true, the build cause is external => local data are not up to date
    if (pullData || timeslotSetData.isEmpty) {
      timeslotSetData =
          ModelCtrl.cloneMap(ModelCtrl().getTimeslotSet(widget.scheduleName, widget.scheduleItemIdx, widget.timeslotSetIdx) ?? {});
    } else {
      Common.setSavedState('timeslotset_data', timeslotSetData);
    }
    pullData = true;
    ScheduleDataPosition pos = ScheduleDataPosition(widget.scheduleName, widget.scheduleItemIdx, widget.timeslotSetIdx);
    return SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Common.createFloatingButton(
              size: 55,
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                List timeslots = timeslotSetData[widget.tsKey];
                Map lastTimeslot = timeslots[timeslots.length - 1];
                List<int> lastTime = TimeTool.parseTimeStr(lastTimeslot['start_time']) ?? [0, 0, 0];
                List<int> startTime = [];
                if (TimeTool.compareTimes(lastTime, [23, 50, 00]) > 0) {
                  lastTime = [23, 50, 00];
                  lastTimeslot['start_time'] = TimeTool.timeToString(lastTime);
                  startTime = [23, 55, 00];
                } else if (lastTime[0] > 22) {
                  startTime = [23, lastTime[1] + (59 - lastTime[1]) ~/ 2, 0];
                } else {
                  startTime = [lastTime[0] + (24 - lastTime[0]) ~/ 2, 0, 0];
                }
                timeslotSetData[widget.tsKey].add({
                  'start_time': TimeTool.timeToString(startTime),
                  'temperature_set': lastTimeslot['temperature_set']
                });
                setState(() {
                  pullData = false;
                });
              }),
          const SizedBox(width: 30),
          Common.createFloatingButton(
            size: 55,
            icon: const Icon(Icons.check, color: Colors.white),
            //backColor: Colors.green.shade700,
            onPressed: () {
              ModelCtrl()
                  .setTimeslotSet(widget.scheduleName, widget.scheduleItemIdx, widget.timeslotSetIdx, ModelCtrl.cloneMap(timeslotSetData));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      const SizedBox(height: 10),
      Common.createWeekChips(widget.scheduleName, widget.scheduleItemIdx, widget.timeslotSetIdx, timeslotSetData, passiveMode: true),
      const SizedBox(height: 10),
      Row(
          children: Timeslots.timeslotsBuilder(context, pos, timeslotSetData, widget.tsKey, false,
              timeSlotBuilder: Timeslots.buildTimeslotCompact)),
      const SizedBox(height: 20),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: Timeslots.timeslotsBuilder(context, pos, timeslotSetData, widget.tsKey, false, timeSlotBuilder: buildTimeslotEditor),
      ),
      // Widget to avoid content being hidden by navbar
      const SizedBox(height: 55)
    ]));
  }

  Widget buildTimeslotEditor(
      List<int> startTime, List<int> endTime, ScheduleDataPosition schedulePos, List timeslotsData, Map tempSet, bool isActive) {
    double minHeight = 120;
    double bottomPadding = 12;
    Color color = Color(ModelCtrl.getGUIParamHex(tempSet, 'iconColor', 0xFF000000));

    Map? scheduleItem = ModelCtrl().getScheduleItem(widget.scheduleName, widget.scheduleItemIdx);
    List<String> scheduleItemDevs = [];
    if (scheduleItem != null) {
      scheduleItemDevs = (scheduleItem['devices'] as List).map((e) => e as String).toList();
    }
    List filtredDevices =
        (tempSet['devices'] as List).where((element) => scheduleItemDevs.contains(element['device_name'])).toList();
    filtredDevices.sort((a, b) => Common.compareDevices(a['device_name'], b['device_name']));

    return IntrinsicHeight(
        //padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
      // This invisible widget forces the entire tree to have a minimum height
      SizedBox(height: minHeight),
      // Widget that shows the date range of this timeslot set
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _buildTimeRange(timeslotSetData[widget.tsKey], startTime, endTime, schedulePos.timeslotIdx, setState),
      ),
      const SizedBox(width: 10),
      Column(children: [
        // Widget that shows the "Temperature Set" (rectangle with color and alias)
        Expanded(
            child: InkWell(
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                      color: color,
                      //border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Center(
                      child: Text(tempSet['alias'],
                          style: TextStyle(fontWeight: FontWeight.bold, color: Common.contrastColor(color)))),
                ),
                onTap: () {
                  TemperatureSetsUtils.pickTemperatureSet(context, widget.scheduleName, tempSet['alias'],
                      onValidate: (selTempSet) {
                    timeslotsData[schedulePos.timeslotIdx]['temperature_set'] = selTempSet;
                    setState(() {
                      pullData = false;
                    });
                  });
                })),
        SizedBox(height: bottomPadding),
      ]),
      const SizedBox(width: 10),
      // Widget that shows the list of (device, setpoint) pairs for temperature set
      Expanded(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: filtredDevices.map((dev) => _buildDeviceSetpoint(dev)).toList() + [SizedBox(height: bottomPadding)],
      )),
    ]));
  }

  List<Widget> _buildTimeRange(List timeslotsData, List<int> startTime, List<int> endTime, int tsIndex,
      void Function(void Function()) setState) {
    List<Widget> list = [];

    Widget upButton = InkWell(
        child: Icon(Icons.keyboard_arrow_up_rounded, size: 35, color: AppTheme().focusColor),
        onTap: () {
          List<int> newTime = TimeTool.addTime(endTime, [0, -10, 0], precision: 10);
          timeslotsData[tsIndex + 1]['start_time'] = TimeTool.timeToString(newTime);
          setState(() {
            pullData = false;
          });
        });
    Widget downButton = InkWell(
        child: Icon(Icons.keyboard_arrow_down, size: 35, color: AppTheme().focusColor),
        onTap: () {
          List<int> newTime = TimeTool.addTime(startTime, [0, 10, 0], precision: 10);
          timeslotsData[tsIndex]['start_time'] = TimeTool.timeToString(newTime);
          setState(() {
            pullData = false;
          });
        });

    /*Widget deleteBtn =
        Common.createCircleIconButton(Icons.cancel, iconColor: Common.getErrorColor(), backColor: Colors.white, onPressed: () {
      timeslotsData.removeAt(tsIndex);
      setState(() {
        pullData = false;
      });
    });*/

    Widget menuBtn = Common.createPopupMenu(
      [
        MyMenuItem(Icons.edit, wcLocalizations().timeslotAddAfter, 'add'),
        MyMenuItem(Icons.cancel_outlined, wcLocalizations().removeAction, 'delete')
      ],
      //iconColor: Colors.white,
      onSelected: (itemValue) async {
        switch (itemValue) {
          case 'add':
            Map currentTimeslot = timeslotsData[tsIndex];
            List<int> currentTime = TimeTool.parseTimeStr(currentTimeslot['start_time']) ?? [0, 0, 0];
            List<int> nextTime = [24, 0, 0];
            if (tsIndex < timeslotsData.length - 1) {
              nextTime = TimeTool.parseTimeStr(timeslotsData[tsIndex + 1]['start_time']) ?? [24, 0, 0];
            }

            // We calculate start time for the new timeslot
            List<int> diff = TimeTool.subTime(nextTime, currentTime);
            List<int> newTime = TimeTool.fromMinutes(TimeTool.getTotalMinutes(diff) ~/ 2);
            newTime = TimeTool.addTime(currentTime, newTime, precision: 10);
            timeslotSetData[widget.tsKey].insert(tsIndex + 1,
                {'start_time': TimeTool.timeToString(newTime), 'temperature_set': currentTimeslot['temperature_set']});
            setState(() {
              pullData = false;
            });
            break;
          case 'delete':
            timeslotsData.removeAt(tsIndex);
            setState(() {
              pullData = false;
            });
            break;
        }
      },
    );

    if (tsIndex == 0) {
      list.add(_buildTime(startTime, passiveMode: true));
      list.add(const SizedBox(height: 20));
    } else {
      list.add(downButton);
    }

    list.add(menuBtn);

    bool passiveMode = (endTime[0] == 24);
    if (!passiveMode) {
      list.add(upButton);
    } else {
      list.add(const SizedBox(height: 35));
    }
    list.add(_buildTime(endTime, passiveMode: passiveMode));

    return list;
  }

  static Widget _buildDeviceSetpoint(Map data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${data['device_name']}: '),
        Text('${data['setpoint']}°',
            style: TextStyle(fontSize: 16, color: AppTheme().focusColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  static Widget _buildTime(List<int> time, {bool passiveMode = false}) {
    int hour = time[0];
    if (hour == 24) {
      hour = 0;
    }
    Widget text = Text(
      '${hour.toString().padLeft(2, '0')}H${time[1].toString().padLeft(2, '0')}',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppTheme().normalTextColor,
      ),
    );
    if (passiveMode) {
      return text;
    } else {
      return InkWell(
          child: text,
          onTap: () {
            //
          });
    }
  }
}

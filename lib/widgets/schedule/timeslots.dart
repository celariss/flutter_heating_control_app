import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/timetool.dart';

class Timeslots {
  static List<Widget> timeslotsBuilder(BuildContext context, ScheduleDataPosition schedulePos, Map timeslotSetData, String key,
      {required Widget Function(
              List<int> startTime, List<int> endTime, ScheduleDataPosition schedulePos, List timeslotsData, Map tempSet)
          timeSlotBuilder}) {
    List<Widget> timeslots = [];

    List<dynamic> timeslotsData = timeslotSetData[key];
    List<int> startTime = [0, 0, 0];
    for (int tsIndex = 0; tsIndex < timeslotsData.length; tsIndex++) {
      List<int> endTime;
      if (tsIndex == timeslotsData.length - 1) {
        endTime = [24, 0, 0];
      } else {
        endTime = TimeTool.parseTimeStr(timeslotsData[tsIndex + 1]['start_time']) ?? startTime;
      }
      // Get the timeslot color from the temperature set name
      String tempSetName = timeslotsData[tsIndex]['temperature_set'];
      Map tempSet = ModelCtrl().buildTemperatureSet(tempSetName, schedulePos.scheduleName);
      schedulePos = ScheduleDataPosition.clone(schedulePos);
      schedulePos.timeslotIdx = tsIndex;
      timeslots.add(timeSlotBuilder(startTime, endTime, schedulePos, timeslotsData, tempSet));
      startTime = endTime;
    }

    return timeslots;
  }

  static Widget buildTimeslotCompact(
      List<int> startTime, List<int> endTime, ScheduleDataPosition schedulePos, List timeslotsData, Map tempSet) {
    double timeslotsHeight = 20.0;
    Color color = Color(ModelCtrl.getGUIParamHex(tempSet, 'iconColor', 0xFF000000));
    int flexValue = endTime[0] * 12 + (endTime[1] ~/ 5) - (startTime[0] * 12 + (startTime[1] ~/ 5));

    BoxDecoration deco = BoxDecoration(
      color: color,
      shape: BoxShape.rectangle,
      borderRadius: (timeslotsData.length == 1)
          ? BorderRadius.horizontal(left: Radius.circular(timeslotsHeight), right: Radius.circular(timeslotsHeight))
          : (schedulePos.timeslotIdx == 0)
              ? BorderRadius.horizontal(left: Radius.circular(timeslotsHeight))
              : (schedulePos.timeslotIdx == timeslotsData.length - 1)
                  ? BorderRadius.horizontal(right: Radius.circular(timeslotsHeight))
                  : null,
    );

    return Flexible(
        flex: flexValue,
        child: Container(
          height: timeslotsHeight,
          decoration: deco,
        ));
  }
}

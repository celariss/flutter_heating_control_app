import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import '../timeslotset/timeslotsetpage.dart';
import 'timeslots.dart';

class TimeslotsSet extends StatelessWidget {
  final String scheduleName;
  final int scheduleItemIdx;
  final int timeslotSetIdx;
  final Map timeslotSetData;

  const TimeslotsSet(
      {super.key,
      required this.timeslotSetData,
      required this.scheduleName,
      required this.scheduleItemIdx,
      required this.timeslotSetIdx});

  @override
  Widget build(BuildContext context) {
    Map activeSchedule = ModelCtrl().getActiveSchedule();
    bool iscurrentScheduleActive = activeSchedule.containsKey('alias') && activeSchedule['alias'] == scheduleName;
    bool fortnightMode = timeslotSetData.containsKey('timeslots_A');
    // 0: none, 1: week B, 2: week A or weeks A&B
    int activeWeek = 0;
    DateTime now = DateTime.now();
    if (iscurrentScheduleActive && timeslotSetData['dates'].contains(now.weekday.toString())) {
      activeWeek = 2;
      if (fortnightMode) {
        activeWeek = (weekNumber(now)%2==0) ? 2 : 1;
      }
    }
    List<Widget> widgets = [
      Common.createWeekChips(scheduleName, scheduleItemIdx, timeslotSetIdx, timeslotSetData),
      buildTimeSlotsInkWell(context, fortnightMode ? 'timeslots_A' : 'timeslots', fortnightMode ? 2 : 0, activeWeek==2),
    ];
    if (fortnightMode) {
      widgets.add(const SizedBox(height:10));
      widgets.add(buildTimeSlotsInkWell(context, 'timeslots_B', 1, activeWeek==1));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: [
      _timeslotsSetMenuBuilder(
        context, ScheduleDataPosition(scheduleName, scheduleItemIdx, timeslotSetIdx), timeslotSetData),
        Expanded(
            child: Column(children: widgets),
        )
      ]);
  }

  Widget buildTimeSlotsInkWell(BuildContext context, String tsKey, int weekNumber, bool isActive) {
    List<Widget> children = [];
    if (weekNumber==1) {
      children.add(Text('sB', style: TextStyle(color: AppTheme().focusColor, fontWeight: FontWeight.bold, fontSize: 15),));
      children.add(const SizedBox(width: 5));
    } else if (weekNumber==2) {
      children.add(Text('sA', style: TextStyle(color: AppTheme().focusColor, fontWeight: FontWeight.bold, fontSize: 15),));
      children.add(const SizedBox(width: 5));
    }
    children.addAll(Timeslots.timeslotsBuilder(
          context, ScheduleDataPosition(scheduleName, scheduleItemIdx, timeslotSetIdx), timeslotSetData, tsKey, isActive,
          timeSlotBuilder: Timeslots.buildTimeslotCompact));
    
    return InkWell(
      onTap: () {
        NavbarNotifier.hideBottomNavBar = false;
        Common.navBarNavigate(context, TimeSlotSetPage.route, isRootNavigator: false, arguments: {
          'scheduleName': scheduleName,
          'scheduleItemIdx': scheduleItemIdx,
          'timeslotSetIdx': timeslotSetIdx,
          'timeslotSetData': timeslotSetData,
          'tsKey': tsKey
        });
      },
      child: Row(crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
      ));
  }

  static Widget _timeslotsSetMenuBuilder(BuildContext context, ScheduleDataPosition pos, Map timeslotSetData) {
    return Common.createPopupMenu(
      [MenuItem_(Icons.copy, 'Quinzaine on/off', 'switch_mode'),
       MenuItem_(Icons.copy, 'Dupliquer', 'clone'),
       MenuItem_(Icons.cancel_outlined, 'Supprimer', 'delete')],
      //iconColor: Colors.white,
      onSelected: (itemValue) async {
        switch (itemValue) {
          case 'switch_mode':
          Map timeslotSetData_ = ModelCtrl.cloneMap(timeslotSetData);
          if (timeslotSetData_.containsKey('timeslots')) {
            timeslotSetData_['timeslots_A'] = timeslotSetData_['timeslots'];
            timeslotSetData_['timeslots_B'] = timeslotSetData_['timeslots'];
            timeslotSetData_.remove('timeslots');
          }
          else {
            timeslotSetData_['timeslots'] = timeslotSetData_['timeslots_A'];
            timeslotSetData_.remove('timeslots_A');
            timeslotSetData_.remove('timeslots_B');
          }
          ModelCtrl().setTimeslotSet(pos.scheduleName, pos.scheduleItemIdx, pos.timeslotSetIdx, timeslotSetData_);
          break;

          case 'clone':
            Map timeslotSetData_ = ModelCtrl.cloneMap(timeslotSetData);
            timeslotSetData_['dates'] = [];
            ModelCtrl().createTimeSlotSet(pos.scheduleName, pos.scheduleItemIdx, data: timeslotSetData_);
            break;

          case 'delete':
            if (timeslotSetData['dates'].length > 0) {
              Common.showErrorDialog(
                  context, "Certains jours de la semaine sont encore affectés à cette plage hebdomadaire");
            } else {
              bool result = await Common.showWarningDialog(
                  context, "Etes-vous sûr de vouloir supprimer cette plage hebdomadaire ?");
              if (result) {
                ModelCtrl().deleteScheduleItemTS(pos.scheduleName, pos.scheduleItemIdx, pos.timeslotSetIdx);
              }
            }
            break;
        }
      },
    );
  }
}

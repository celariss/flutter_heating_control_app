/// This file defines TimeslotsSet widget 
/// 
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import '../timeslotset/timeslotsetpage.dart';
import '../../utils/localizations.dart';
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
      children.add(Text(wcLocalizations().timeslotWeekB, style: TextStyle(color: AppTheme().focusColor, fontWeight: FontWeight.bold, fontSize: 15),));
      children.add(const SizedBox(width: 5));
    } else if (weekNumber==2) {
      children.add(Text(wcLocalizations().timeslotWeekA, style: TextStyle(color: AppTheme().focusColor, fontWeight: FontWeight.bold, fontSize: 15),));
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
      [MyMenuItem(Icons.copy, wcLocalizations().timeslotsFortnightSwitch, 'switch_mode'),
       MyMenuItem(Icons.copy, wcLocalizations().cloneAction, 'clone'),
       MyMenuItem(Icons.cancel_outlined, wcLocalizations().removeAction, 'delete')],
      //iconColor: Colors.white,
      onSelected: (itemValue) async {
        switch (itemValue) {
          case 'switch_mode':
          bool changed = false;
          Map timeslotSetData_ = ModelCtrl.cloneMap(timeslotSetData);
          if (timeslotSetData_.containsKey('timeslots')) {
            timeslotSetData_['timeslots_A'] = timeslotSetData_['timeslots'];
            timeslotSetData_['timeslots_B'] = timeslotSetData_['timeslots'];
            timeslotSetData_.remove('timeslots');
            changed = true;
          }
          else {
            bool result = await Common.showWarningDialog(context, wcLocalizations().removeFortnightConfirmation);
            if (result) {
              timeslotSetData_['timeslots'] = timeslotSetData_['timeslots_A'];
              timeslotSetData_.remove('timeslots_A');
              timeslotSetData_.remove('timeslots_B');
              changed = true;
            }
          }
          if (changed) {
            ModelCtrl().setTimeslotSet(pos.scheduleName, pos.scheduleItemIdx, pos.timeslotSetIdx, timeslotSetData_);
          }
          break;

          case 'clone':
            Map timeslotSetData_ = ModelCtrl.cloneMap(timeslotSetData);
            timeslotSetData_['dates'] = [];
            ModelCtrl().createTimeSlotSet(pos.scheduleName, pos.scheduleItemIdx, data: timeslotSetData_);
            break;

          case 'delete':
            if (timeslotSetData['dates'].length > 0) {
              Common.showErrorDialog(
                  context, wcLocalizations().timeslotsErrorNotEmpty);
            } else {
              bool result = await Common.showWarningDialog(
                  context, wcLocalizations().removeConfirmation('timeslots', ''));
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

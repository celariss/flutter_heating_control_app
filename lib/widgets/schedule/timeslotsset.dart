import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../timeslotset/timeslotsetpage.dart';
import 'timeslots.dart';

class TimeslotsSet extends StatelessWidget {
  final String scheduleName;
  final int scheduleItemIdx;
  final int timeslotSetIdx;
  final Map timeslotSetData;

  const TimeslotsSet(
      {Key? key,
      required this.timeslotSetData,
      required this.scheduleName,
      required this.scheduleItemIdx,
      required this.timeslotSetIdx})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _timeslotsSetMenuBuilder(
          context, ScheduleDataPosition(scheduleName, scheduleItemIdx, timeslotSetIdx), timeslotSetData),
      Expanded(
          child: Column(children: [
        Common.createWeekChips(scheduleName, scheduleItemIdx, timeslotSetIdx, timeslotSetData),
        InkWell(
          onTap: () {
            NavbarNotifier.hideBottomNavBar = false;
            Common.navBarNavigate(context, TimeSlotSetPage.route, isRootNavigator: false, arguments: {
              'scheduleName': scheduleName,
              'scheduleItemIdx': scheduleItemIdx,
              'timeslotSetIdx': timeslotSetIdx,
              'timeslotSetData': timeslotSetData
            });
          },
          child: Row(
              children: Timeslots.timeslotsBuilder(
                  context, ScheduleDataPosition(scheduleName, scheduleItemIdx, timeslotSetIdx), timeslotSetData,
                  timeSlotBuilder: Timeslots.buildTimeslotCompact)),
        ),
      ])),
    ]);
  }

  static Widget _timeslotsSetMenuBuilder(BuildContext context, ScheduleDataPosition pos, Map timeslotSetData) {
    return Common.createPopupMenu(
      [MenuItem_(Icons.copy, 'Dupliquer', 'clone'), MenuItem_(Icons.cancel_outlined, 'Supprimer', 'delete')],
      //iconColor: Colors.white,
      onSelected: (itemValue) async {
        switch (itemValue) {
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

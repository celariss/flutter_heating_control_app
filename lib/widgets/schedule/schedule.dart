import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import 'scheduleitem.dart';

class Schedule {
  static Widget scheduleBuilder(BuildContext context, Map scheduleData) {
    String name = scheduleData['alias'];
    Widget title = Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        const SizedBox(width: 20),
        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _scheduleMenuBuilder(context, scheduleData, iconColor: Colors.white),
        const SizedBox(width: 10),
      ]),
    ]);

    List<Widget> itemWidgets = [title];
    int idx = 0;
    scheduleData['schedule_items'].forEach((scheduleItemData) {
      itemWidgets.add(const SizedBox(height: 5));
      itemWidgets.add(ScheduleItem(scheduleItemData: scheduleItemData, scheduleName: name, scheduleItemIdx: idx));
      idx += 1;
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
          color: Colors.grey.shade700,
          //border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: itemWidgets)),
    );
  }

  static Widget scheduleTileBuilder(BuildContext context, Map scheduleData, {bool dense = false}) {
    Widget leading = Icon(Icons.schedule, color: AppTheme().focusColor);
    String name = scheduleData['alias'];
    double fontSize = dense ? Common.getRadioListTextSize() : Common.getListViewTextSize();
    Widget title = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(name, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
              ]),
            ] +
            ((dense == true)
                ? []
                : [
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      _scheduleMenuBuilder(context, scheduleData),
                    ]),
                  ]));

    if (dense) {
      return Row(
        children: [leading, const SizedBox(width: 10), title],
      );
    }

    int idx = 0;
    List<Widget> children = (scheduleData['schedule_items'] as List).map((scheduleItemData) {
      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: ScheduleItem(scheduleItemData: scheduleItemData, scheduleName: name, scheduleItemIdx: idx++),
      );
    }).toList();

    bool isExpanded = Common.getSavedState('schedule_' + scheduleData['alias'], false) as bool;
    return StatefulBuilder(
      key: Key(scheduleData['alias']),
      builder: (BuildContext context, setState) {
        Widget title_ = title;
        return ExpansionTile(
          textColor: AppTheme().focusColor,
          collapsedTextColor: AppTheme().specialTextColor,
          iconColor: AppTheme().focusColor,
          collapsedIconColor: AppTheme().specialTextColor,
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            Common.setSavedState('schedule_' + scheduleData['alias'], expanded);
            setState(() {
              isExpanded = expanded;
            });
          },
          leading: leading,
          title: title_,
          children: children,
        );
      },
    );
  }

  static void _onEditPlanningValidate(BuildContext context, Map scheduleData, String tapedName) {
    if (scheduleData['alias'] != tapedName) {
      if (ModelCtrl().getSchedule(tapedName).isNotEmpty) {
        Common.showSnackBar(context, "Le nom '$tapedName' est d??j?? utilis?? ...",
            backColor: AppTheme().errorColor, duration_ms: 4000);
      } else {
        ModelCtrl().onScheduleNameChanged(scheduleData['alias'], tapedName);
      }
    }
  }

  static Widget _scheduleMenuBuilder(BuildContext context, Map scheduleData, {Color? iconColor}) {
    String name = scheduleData['alias'];
    return Common.createPopupMenu(
      [
        MenuItem_(Icons.edit, 'Editer', 'edit_name'),
        MenuItem_(Icons.add, 'Ajouter un sous-planning', 'add_scheduleitem'),
        MenuItem_(Icons.copy, 'Dupliquer ce planning', 'clone_schedule'),
        MenuItem_(Icons.cancel_outlined, 'Supprimer', 'delete')
      ],
      iconColor: iconColor,
      onSelected: (itemValue) async {
        switch (itemValue) {
          case 'edit_name':
            Common.editScheduleProperties(context, scheduleData, _onEditPlanningValidate);
            break;
          case 'add_scheduleitem':
            ModelCtrl().createScheduleItem(name);
            break;
          case 'clone_schedule':
            ModelCtrl().cloneSchedule(name);
            break;
          case 'delete':
            bool result =
                await Common.showWarningDialog(context, "Etes-vous s??r de vouloir supprimer le planning '$name' ?");
            if (result) {
              ModelCtrl().deleteSchedule(name);
            }
            break;
        }
      },
    );
  }
}

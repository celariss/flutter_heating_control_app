import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import '../../utils/localizations.dart';
import 'scheduleitem.dart';

class Schedule {
  // If dense is true, returns a widget that contains only a schedule title
  static Widget scheduleTileBuilder(BuildContext context, Map scheduleData) {
    Widget leading = Icon(Icons.schedule, color: AppTheme().focusColor);
    String name = scheduleData['alias'];

    Widget title = _createTitleWidget(context, scheduleData);

    int idx = 0;
    List<Widget> children = (scheduleData['schedule_items'] as List).map((scheduleItemData) {
      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: ScheduleItem(scheduleItemData: scheduleItemData, scheduleName: name, scheduleItemIdx: idx++),
      );
    }).toList();

    double rightPadding = 0;
    switch (Theme.of(context).platform) {
        case TargetPlatform.linux:
        case TargetPlatform.windows:
        case TargetPlatform.macOS:
          rightPadding = 35;
          break;
        default:
    }

    bool isExpanded = Common.getSavedState('schedule_${scheduleData['alias']}', false) as bool;
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
            Common.setSavedState('schedule_${scheduleData['alias']}', expanded);
            setState(() {
              isExpanded = expanded;
            });
          },
          tilePadding: EdgeInsets.fromLTRB(0, 0, rightPadding, 0),
          leading: leading,
          title: title_,
          children: children,
        );
      },
    );
  }

  static Widget _createTitleWidget(BuildContext context, Map scheduleData) {
    double fontSize = Common.getListViewTextSize();
    String name = scheduleData['alias'];

    // Creating title widget with schedule name and the active tag
    List<Widget> titleChildren = [];
    titleChildren.add(Text(name, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)));
    Map activeSchedule = ModelCtrl().getActiveSchedule();
    if (activeSchedule.isNotEmpty) {
      // If the current schedule is the first active, we create a tag
      if (activeSchedule['alias'] == scheduleData['alias']) {
        titleChildren.add(Common.createActiveScheduleTag());
      // If the current schedule is the first is in the active list, we create a 'parent' tag with a different color
      } else if (ModelCtrl().getActiveScheduleInheritanceNames().contains(name)) {
          titleChildren.add(Common.createActiveScheduleTag(true));
      }
    }
    Widget title = Row(mainAxisAlignment: MainAxisAlignment.start, children: titleChildren);

    // Adding parent schedule name to the title widget
    if (scheduleData.containsKey('parent_schedule')) {
      Widget subTitle = Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                color: AppTheme().background2Color,
                borderRadius: const BorderRadius.all(Radius.circular(7.0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //SizedBox(width: 10),
                Text(
                  wcLocalizations().scheduleParentPrefix,
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.normal)),
                Text(
                  " < ${scheduleData['parent_schedule']} >",
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
                SizedBox(),
              ],
            ),
          );
      title = Expanded(child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, subTitle]
      ));
    }

    // Adding schedule menu to the title widget
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        title,
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          _scheduleMenuBuilder(context, scheduleData),
        ]),
      ]);
  }

  static void _onEditPlanningValidate(BuildContext context, Map scheduleData, String tapedName, String chosenParent) {
    String alias = scheduleData['alias'];
    String parent = scheduleData.containsKey('parent_schedule') ? scheduleData['parent_schedule'] : '';
    if (alias != tapedName || parent != chosenParent) {
      if ((alias != tapedName) && ModelCtrl().getSchedule(tapedName).isNotEmpty) {
        Common.showSnackBar(context, wcLocalizations().errorDuplicateKey(tapedName),
            backColor: AppTheme().errorColor, durationMs: 4000);
      } else if ((parent != chosenParent) && (chosenParent.isNotEmpty) && ModelCtrl().getSchedule(chosenParent).isEmpty) {
        Common.showSnackBar(context, wcLocalizations().schedulePageErrorBadParent,
            backColor: AppTheme().errorColor, durationMs: 4000);
      } else {
        ModelCtrl().onSchedulePropertiesChanged(scheduleData['alias'], tapedName, chosenParent);
      }
    }
  }

  static Widget _scheduleMenuBuilder(BuildContext context, Map scheduleData, {Color? iconColor}) {
    String name = scheduleData['alias'];
    return Common.createPopupMenu(
      [
        MyMenuItem(Icons.edit, wcLocalizations().editAction(''), 'edit'),
        MyMenuItem(Icons.add, wcLocalizations().addAction('subschedule'), 'add_scheduleitem'),
        MyMenuItem(Icons.copy, wcLocalizations().cloneAction, 'clone_schedule'),
        MyMenuItem(Icons.cancel_outlined, wcLocalizations().removeAction, 'delete')
      ],
      iconColor: iconColor,
      onSelected: (itemValue) async {
        switch (itemValue) {
          case 'edit':
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
                await Common.showWarningDialog(context, wcLocalizations().removeConfirmation('schedule', name));
            if (result) {
              ModelCtrl().deleteSchedule(name);
            }
            break;
        }
      },
    );
  }
}

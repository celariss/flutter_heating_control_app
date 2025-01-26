import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
import '../../utils/localizations.dart';
import 'timeslotsset.dart';

class ScheduleItem extends StatelessWidget {
  final String scheduleName;
  final int scheduleItemIdx;
  final Map scheduleItemData;

  const ScheduleItem(
      {super.key, required this.scheduleItemData, required this.scheduleName, required this.scheduleItemIdx});

  @override
  Widget build(BuildContext context) {
    List timeslotsSets = scheduleItemData['timeslots_sets'];
    
    double rightPadding = 0;
    switch (Theme.of(context).platform) {
        case TargetPlatform.linux:
        case TargetPlatform.windows:
        case TargetPlatform.macOS:
          rightPadding = 35;
          break;
        default:
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 8,
          ),
          // First line : contains list of devices
          Container(
              padding: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  color: AppTheme().background3Color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0))),
              child: Row(children: [
                _scheduleItemMenuBuilder(context, scheduleItemData, scheduleName, scheduleItemIdx),
                Flexible(
                  fit: FlexFit.tight,
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 0.0,
                    alignment: WrapAlignment.start,
                    children: buildDeviceList(),
                  ),
                ),
              ])),
          // Second line : contains the timeslots
          Container(
              padding: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  color: AppTheme().background2Color,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10.0))),
              child: ReorderableListView.builder(
                  // The two following lines are here to avoid "viewport has unbounded height" error
                  // and allows the scroll to work in nested listviews
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  //controller: _scrollController,
                  itemCount: timeslotsSets.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      key: Key(index.toString()), 
                      padding: EdgeInsets.fromLTRB(0, 0, rightPadding, 0),
                      child:Column(children: [
                      const SizedBox(height: 3),
                      TimeslotsSet(
                          timeslotSetData: timeslotsSets[index],
                          scheduleName: scheduleName,
                          scheduleItemIdx: scheduleItemIdx,
                          timeslotSetIdx: index),
                      const SizedBox(height: 8),
                    ]));
                  },
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    Map item = timeslotsSets.removeAt(oldIndex);
                    timeslotsSets.insert(newIndex, item);
                    ModelCtrl().onScheduleChanged(scheduleName);
                  }))
        ]),
    );
  }

  static Widget _scheduleItemMenuBuilder(
      BuildContext context, Map scheduleItemData, String scheduleName, int scheduleItemIdx) {
    List<MyMenuItem> menuItemList = [
        MyMenuItem(Common.getDeviceIconData(), wcLocalizations().editAction('eqptlist'), 'edit_devices'),
        MyMenuItem(Icons.add, wcLocalizations().addAction('slots'), 'add_timeslotset'),
        MyMenuItem(Icons.copy, wcLocalizations().cloneAction, 'clone_scheduleitem'),
        MyMenuItem(Icons.cancel_outlined, wcLocalizations().removeAction, 'delete_scheduleitem'),
      ];
    if (scheduleItemIdx > 0) {
      menuItemList.add( MyMenuItem(Icons.keyboard_arrow_up_rounded, wcLocalizations().moveUpAction, 'move_up') );
    }
    if (scheduleItemIdx < ModelCtrl().getSchedule(scheduleName)['schedule_items'].length - 1) {
      menuItemList.add( MyMenuItem(Icons.keyboard_arrow_down, wcLocalizations().moveDownAction, 'move_down') );
    }

    return Common.createPopupMenu(menuItemList,
      onSelected: (itemValue) async {
        switch (itemValue) {
          case 'edit_devices':
            {
              List<String> devices = List<String>.from(scheduleItemData['devices'] as List);
              Common.pickDevices(
                context,
                devices,
                onValidate: () {
                  String device = ModelCtrl().setDevicesInScheduleItem(scheduleName, scheduleItemIdx, devices);
                  if (device.isNotEmpty) {
                    Common.showSnackBar(context, wcLocalizations().errorDuplicateDevice(device),
                      backColor: AppTheme().errorColor, durationMs: 4000);
                  }
                },
              );
            }
            break;
          case 'clone_scheduleitem':
            Common.pickSchedule(context, scheduleName, onValidate: (targetScheduleName) {
              ModelCtrl().cloneScheduleItem(scheduleName, scheduleItemIdx, targetScheduleName);
            });
            break;
          case 'delete_scheduleitem':
            bool result =
                await Common.showWarningDialog(context, wcLocalizations().removeConfirmation('subschedule', ''));
            if (result) {
              ModelCtrl().deleteScheduleItem(scheduleName, scheduleItemIdx);
            }
            break;
          case 'add_timeslotset':
            ModelCtrl().createTimeSlotSet(scheduleName, scheduleItemIdx);
            break;
          case 'move_up':
            ModelCtrl().swapScheduleItems(scheduleName, scheduleItemIdx, scheduleItemIdx - 1);
            break;
          case 'move_down':
            ModelCtrl().swapScheduleItems(scheduleName, scheduleItemIdx, scheduleItemIdx + 1);
            break;
        }
      },
    );
  }

  List<Widget> buildDeviceList() {
    List<Widget> result = [];
    scheduleItemData['devices'].forEach((device) {
      result.add(_buildDeviceChip(device));
    });
    return result;
  }

  /*List<Widget> buildTimeslotSets() {
    List<Widget> result = [];
    int idx = 0;
    scheduleItemData['timeslots_sets'].forEach((timeslotSetData) {
      result.add(const SizedBox(height: 10));
      result.add(TimeslotsSet(
          timeslotSetData: timeslotSetData,
          scheduleName: scheduleName,
          scheduleItemIdx: scheduleItemIdx,
          timeslotSetIdx: idx));
      result.add(const SizedBox(height: 10));
      idx += 1;
    });
    return result;
  }*/

  Widget _buildDeviceChip(String deviceName) {
    return Common.wrapChip(Chip(
      backgroundColor: AppTheme().selectedColor,
      elevation: AppTheme().defaultElevation,
      //showCheckmark: false,
      label: Text(deviceName),
    ));
  }
}

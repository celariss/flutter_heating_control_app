import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/theme.dart';
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
    List<Widget> moveBtns = [];
    Widget upBtn = InkWell(
        child: Icon(Icons.keyboard_arrow_up_rounded, size: 35, color: AppTheme().focusColor),
        onTap: () {
          ModelCtrl().swapScheduleItems(scheduleName, scheduleItemIdx, scheduleItemIdx - 1);
        });
    Widget downBtn = InkWell(
        child: Icon(Icons.keyboard_arrow_down, size: 35, color: AppTheme().focusColor),
        onTap: () {
          ModelCtrl().swapScheduleItems(scheduleName, scheduleItemIdx, scheduleItemIdx + 1);
        });
    if (scheduleItemIdx > 0) {
      moveBtns.add(upBtn);
    }
    if (scheduleItemIdx < ModelCtrl().getSchedule(scheduleName)['schedule_items'].length - 1) {
      moveBtns.add(downBtn);
    }

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
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        const SizedBox(
          height: 8,
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: AppTheme().background3Color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0))),
            child: Row(children: [
              _scheduleItemMenuBuilder(context, scheduleItemData, scheduleName, scheduleItemIdx),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 0.0,
                  alignment: WrapAlignment.start,
                  children: buildDeviceList(),
                ),
              ),
              Flexible(
                flex: 0,
                fit: FlexFit.tight,
                child: Wrap(alignment: WrapAlignment.end, children: [Column(children: moveBtns)]),
              )
            ])),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
    return Common.createPopupMenu(
      [
        MenuItem_(Common.getDeviceIconData(), 'Editer la liste des vannes', 'edit_devices'),
        MenuItem_(Icons.add, 'Ajouter une plage hebdomadaire', 'add_timeslotset'),
        MenuItem_(Icons.copy, 'Dupliquer ce sous-planning', 'clone_scheduleitem'),
        MenuItem_(Icons.cancel_outlined, 'Supprimer ce sous-planning', 'delete_scheduleitem'),
      ],
      onSelected: (itemValue) async {
        switch (itemValue) {
          case 'edit_devices':
            {
              List<String> devices = List<String>.from(scheduleItemData['devices'] as List);
              Common.pickDevices(
                context,
                devices,
                onValidate: () {
                  scheduleItemData['devices'] = devices;
                  ModelCtrl().onScheduleChanged(scheduleName);
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
                await Common.showWarningDialog(context, "Etes-vous sûr de vouloir supprimer ce sous-planning ?");
            if (result) {
              ModelCtrl().deleteScheduleItem(scheduleName, scheduleItemIdx);
            }
            break;
          case 'add_timeslotset':
            ModelCtrl().createTimeSlotSet(scheduleName, scheduleItemIdx);
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

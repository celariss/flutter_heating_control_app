/// Common helpers
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../utils/platform.dart';

import 'model_ctrl.dart';
import 'settings.dart';
import 'theme.dart';

double? str2Double(String str) {
  try {
    return double.parse(str);
  } catch (formatException) {}
  return null;
}

double floor(double value, double precision, {double? minValue, double? maxValue}) {
  value = (value/precision).floor() * precision;
  if (minValue!=null) {
    value = max(minValue, value);
  }
  if (maxValue!=null) {
    value = min(maxValue, value);
  }
  return value;
}

class MenuItem_ {
  final IconData icon;
  final String text;
  final String value;
  MenuItem_(this.icon, this.text, this.value);
}

enum DlgButtons { close, okCancel, continueCancel }

class ScheduleDataPosition {
  String scheduleName;
  int scheduleItemIdx;
  int timeslotSetIdx;
  int timeslotIdx;
  ScheduleDataPosition(this.scheduleName, this.scheduleItemIdx, [this.timeslotSetIdx = 0, this.timeslotIdx = 0]);
  ScheduleDataPosition.clone(ScheduleDataPosition right)
      : scheduleName = right.scheduleName,
        scheduleItemIdx = right.scheduleItemIdx,
        timeslotSetIdx = right.timeslotSetIdx,
        timeslotIdx = right.timeslotIdx;
}

class Common {
  static IconData getDeviceIconData() {
    //return Icons.thermostat;
    //return Icons.local_fire_department;
    return Icons.whatshot;
  }

  static IconData getTempSetIconData() {
    return Icons.vertical_split;
  }

  static IconData getManualModeIcon() {
    //return Icons.pan_tool;
    return Icons.front_hand;
  }

  static double getRadioListTextSize() {
    return 13;
  }
  
  static double getListViewTextSize() {
    return 18;
  }

  static final Map _savedStates = {};
  static void setSavedState(String key, dynamic value) {
    _savedStates[key] = value;
  }

  static dynamic getSavedState(String key, [dynamic defaultValue]) {
    if (_savedStates.containsKey(key)) {
      return _savedStates[key];
    }
    return defaultValue;
  }

  static void removeSavedState(String key) {
    if (_savedStates.containsKey(key)) {
      _savedStates.remove(key);
    }
  }

  static Color contrastColor(Color backColor) {
    if (backColor.computeLuminance() > 0.3) {
      return Colors.black;
    }
    return Colors.white;
  }

  static AppBar createAppBar(String title, {List<Widget> actions = const []}) {
    return AppBar(title: Text(title), actions:
        actions + [
        Common.createCircleIcon(
            size: 32,
            icon: Icon(ModelCtrl().isConnectedToCtrlServer() ? Icons.link : Icons.link_off, color: Colors.white),
            backColor: ModelCtrl().isConnectedToCtrlServer() ? Colors.green.shade700 : ModelCtrl().isConnectedToMQTT() ? Colors.orange.shade700 : Colors.red.shade800
          ),
      ]
      );
  }

  static Future<void> navBarNavigate(BuildContext context, String route,
          {bool isDialog = false, bool isRootNavigator = true, Map<String, dynamic>? arguments}) =>
      Navigator.of(context, rootNavigator: isRootNavigator).pushNamed(route, arguments: arguments);

  static void showSnackBar(BuildContext context, String text,
      {Color? backColor, Color? textColor, int duration_ms = 2000}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: duration_ms),
        backgroundColor: backColor ?? Theme.of(context).snackBarTheme.backgroundColor,
        margin: const EdgeInsets.only(bottom: kBottomNavigationBarHeight, right: 2, left: 2),
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  static void hideSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static createCircleIcon({required Icon icon, required double size, required Color backColor}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backColor,
        shape: BoxShape.circle,
      ),
      child: icon,
    );
  }

  static createFloatingButton(
      {required Widget icon, double size = 0, Color? backColor, required void Function() onPressed}) {
    Widget button = FloatingActionButton(
      backgroundColor: backColor ?? AppTheme().focusColor,
      elevation: AppTheme().defaultElevation,
      onPressed: onPressed,
      child: icon,
    );

    if (size == 0) {
      size = 50;
    } else {
      size += 10;
    }
    return Container(width: size, height: size, padding: const EdgeInsets.all(5), child: button);
  }

  static Widget createTextButton(String text, {required void Function()? onPressed}) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppTheme().buttonBackColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          )),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme().buttonTextColor,
        ),
      ),
    );
  }

  static createCircleIconButton(IconData iconData,
      {required void Function() onPressed, Color? iconColor, Color? backColor, double? iconSize}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        elevation: AppTheme().defaultElevation,
        visualDensity: VisualDensity.compact,
        backgroundColor: backColor ?? AppTheme().focusColor,
      ),
      child: Icon(iconData, color: iconColor ?? AppTheme().buttonTextColor),
    );
  }

  static Widget createPopupMenu(List<MenuItem_> menuItems,
      {required void Function(dynamic) onSelected, Color? iconColor}) {
    return PopupMenuButton(
      color: AppTheme().background2Color,
      onSelected: onSelected,
      icon: Icon(Icons.more_vert, color: iconColor ?? AppTheme().focusColor),
      itemBuilder: (BuildContext bc) {
        return menuItems.map((MenuItem_ menuItem) {
          return PopupMenuItem(
            value: menuItem.value,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Icon(menuItem.icon, color: AppTheme().focusColor),
              const SizedBox(width: 11),
              Text(menuItem.text,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme().focusColor))
            ]),
          );
        }).toList();
      },
    );
  }

  static Future<void> showModalDialog(BuildContext context,
      {required String title,
      required DlgButtons dlgButtons,
      required Widget content,
      void Function()? onValidate}) async {
    await showDialog(
      context: context,
      builder: (context) {
        List<Widget> actions = [];
        switch (dlgButtons) {
          case DlgButtons.close:
            actions = [
              Common.createTextButton(
                'Fermer',
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onValidate != null) {
                    onValidate();
                  }
                },
              ),
            ];
            break;
          case DlgButtons.okCancel:
          case DlgButtons.continueCancel:
            actions = [
              Common.createTextButton(
                'Annuler',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Common.createTextButton(
                dlgButtons == DlgButtons.okCancel ? 'Valider' : 'Continuer',
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onValidate != null) {
                    onValidate();
                  }
                },
              ),
            ];
        }
        return AlertDialog(
            title: Text(title, style: TextStyle(color: AppTheme().focusColor)),
            backgroundColor: AppTheme().background2Color,
            contentPadding: const EdgeInsets.all(0),
            //insetPadding: const EdgeInsets.all(0),
            content: SingleChildScrollView(
              //shrinkWrap: true,
              child: content,
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: actions);
      },
    );
  }

  static Future<void> pickDevices(BuildContext context, List<String> filters,
      {required void Function()? onValidate}) async {
    List<String> devices = ModelCtrl().getDevices().keys.toList();
    devices.sort();

    await showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: 'Sélection des équipements',
        onValidate: onValidate, content: StatefulBuilder(builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: devices.map((dev) => _buildDeviceChip(context, setState, dev, filters)).toList(),
      );
    }));
  }

  static Widget _buildDeviceChip(
      BuildContext context, void Function(void Function()) setState, String deviceName, List<String> filters) {
    return Common.wrapChip(FilterChip(
      backgroundColor: AppTheme().notSelectedColor,
      avatar: Icon(
        Common.getDeviceIconData(),
        //color: Colors.black,
      ),
      showCheckmark: false,
      elevation: 12,
      label: Text(deviceName),
      selected: filters.contains(deviceName),
      selectedColor: AppTheme().selectedColor,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            filters.add(deviceName);
          } else {
            filters.removeWhere((String name) {
              return name == deviceName;
            });
          }
        });
      },
    ));
  }

  static void showErrorDialog(BuildContext context, String alertText) {
    showModalDialog(context, dlgButtons: DlgButtons.close, title: 'Erreur',
        content: StatefulBuilder(builder: (context, setState) {
      return Column(
        children: [
          Center(child: Icon(Icons.error, color: AppTheme().errorColor)),
          const SizedBox(height: 20),
          Center(child: Text(alertText)),
        ],
      );
    }));
  }

  static Future<bool> showWarningDialog(BuildContext context, String alertText, {String title='Confirmation', bool closeBtnOnly=false}) async {
    bool result = false;

    await showModalDialog(context,
        dlgButtons: closeBtnOnly ? DlgButtons.close : DlgButtons.continueCancel,
        title: title,
        onValidate: () => result = true,
        content: Column(
          children: [
            Center(child: Icon(size: 60, Icons.warning, color: AppTheme().warningColor)),
            const SizedBox(height: 20),
            Center(child: Text(alertText)),
          ],
        ));

    return result;
  }

  static Future<Color> showColorPicker(BuildContext context, Color color) async {
    Color result = color;

    await showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: 'Couleur du jeu',
        onValidate: () => result = color,
        content: MaterialPicker(
          pickerColor: color,
          onColorChanged: (value) {
            color = value;
          },
        ));

    return result;
  }

  static Future<void> editScheduleProperties(BuildContext context, Map data,
      void Function(BuildContext context, Map data, String tapedName) onValidate) async {
    var nameCtrl = TextEditingController(text: data['alias']);
    await showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: 'Propriétés du planning',
        onValidate: () => onValidate(context, data, nameCtrl.text),
        content: Column(
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(hintText: 'Nom du planning'),
            ),
          ],
        ));
  }

  static int compareDevices(String devName1, String devName2) {
    for (String key in ModelCtrl().getDevices().keys) {
      if (key==devName1) return -1;
      if (key==devName2) return 1;
    }
    return 0;
  }

  static Future<void> pickSchedule(BuildContext context, String defaultScheduleName,
      {required void Function(String selScheduleName)? onValidate}) async {
    String selectedAlias = defaultScheduleName;
    await showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: "Sélection d'un planning",
        onValidate: () => onValidate!(selectedAlias),
        content: StatefulBuilder(builder: (context, setState) {
          List itemList = ModelCtrl().getSchedules();
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: itemList.map((scheduleData) {
              return RadioListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: const EdgeInsets.all(0),
                value: scheduleData['alias'],
                dense: true,
                groupValue: selectedAlias,
                title: Text(scheduleData['alias'],
                    style: TextStyle(
                        fontSize: Common.getRadioListTextSize(),
                        fontWeight: FontWeight.bold,
                        color: selectedAlias == scheduleData['alias']
                            ? AppTheme().normalTextColor
                            : AppTheme().specialTextColor)),
                onChanged: (selected) {
                  setState(() => selectedAlias = selected);
                },
                selected: scheduleData['alias'] == selectedAlias,
                activeColor: AppTheme().normalTextColor,
              );
            }).toList(),
          );
        }));
  }

  static Future<void> editTemperatureSetProperties(BuildContext context, Map data, String scheduleName,
      void Function(Map data, String scheduleName, Color pickedColor, String tapedName) onValidate) async {
    var nameCtrl = TextEditingController(text: data['alias']);
    Color color = Color(ModelCtrl.getGUIParamHex(data, 'iconColor', Settings().temperatureSetDefaultColor));
    await showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: 'Propriétés du Jeu',
        onValidate: () => onValidate(data, scheduleName, color, nameCtrl.text),
        content: StatefulBuilder(builder: (context, setState) {
          return Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'Nom du jeu'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Flexible(child: SizedBox(height: 30.0, child: Text('Couleur'))),
                  const Spacer(flex: 2),
                  InkResponse(
                    onTap: () {
                      showColorPicker(context, color).then((value) {
                        setState(() => color = value);
                      });
                    },
                    child: Container(
                      width: 30.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        }));
  }

  // Due to a flutter bug, the padding, for any chip widget, depends on the target platform
  static Widget wrapChip(Widget chip) {
    return Padding(
        padding: EdgeInsets.only(
            bottom: PlatformDetails().isDesktop ? 8.0 : 0.0, top: PlatformDetails().isDesktop ? 8.0 : 0.0),
        child: chip);
  }

  // create the row of selectable week days
  static Widget createWeekChips(String scheduleName, int scheduleItemIdx, int timeslotSetIdx, Map timeslotSetData,
      {bool passiveMode = false}) {
    var list = [
      ['1', 'Lu'],
      ['2', 'Ma'],
      ['3', 'Me'],
      ['4', 'Je'],
      ['5', 'Ve'],
      ['6', 'Sa'],
      ['7', 'Di']
    ];
    List<Widget> chips = [];
    List<String> weekDayFilters = List<String>.from(timeslotSetData['dates'] as List);
    for (var day in list) {
      chips.add(Flexible(
        child: Common.wrapChip(FilterChip(
            backgroundColor: AppTheme().notSelectedColor,
            showCheckmark: false,
            elevation: AppTheme().defaultElevation,
            shape: const CircleBorder(side: BorderSide.none),
            label: Text(day[1]),
            selected: weekDayFilters.contains(day[0]),
            selectedColor: AppTheme().selectedColor,
            onSelected: (bool selected) {
              if (selected && !passiveMode) {
                // the ModelCtrl will remove this day from an other timeSlotSet
                ModelCtrl().assignWeekDay(scheduleName, scheduleItemIdx, timeslotSetIdx, day[0]);
              }
            })),
      ));
    }
    return Center(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: chips));
  }
}

/// Common helpers
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library common_helpers;

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../utils/platform.dart';
import '../utils/localizations.dart';

import 'model_ctrl.dart';
import 'settings.dart';
import 'theme.dart';

double? str2Double(String str) {
  try {
    return double.parse(str);
  } catch (formatException) {
    //
  }
  return null;
}

double floor(double value, double precision, {double? minValue, double? maxValue}) {
  value = (value / precision).floor() * precision;
  if (minValue != null) {
    value = max(minValue, value);
  }
  if (maxValue != null) {
    value = min(maxValue, value);
  }
  return value;
}

int weeksBetween(DateTime from, DateTime to) {
  from = DateTime.utc(from.year, from.month, from.day);
  to = DateTime.utc(to.year, to.month, to.day);
  return (to.difference(from).inDays / 7).floor();
}

int weekNumber(DateTime date) {
  // 1/1/2024 is a good reference since it starts on monday
  return ((weeksBetween(DateTime(2024, 1, 1), date) % 52) + 1);
}

class MyMenuItem {
  final IconData icon;
  final String text;
  final String value;
  MyMenuItem(this.icon, this.text, this.value);
}

enum DlgButtons { close, okCancel, continueCancel }

/// Class used to identify the position of a field inside a schedule
/// This position may point a schedule item, a timeslot set inside a schedule item,
/// or a timeslot inside a timeslot set itself inside a schedule item.
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
  /// Returns the [IconData] to use to represent a device/thermostat,
  static IconData getDeviceIconData() {
    //return Icons.thermostat;
    //return Icons.local_fire_department;
    return Icons.whatshot;
  }

  /// Returns the [IconData] to use to represent a temperature set,
  static IconData getTempSetIconData() {
    return Icons.vertical_split;
  }

  /// Returns the [IconData] to use to indicate that a thermostat is in manual mode,
  /// i.e. when the current setpoint is not the setpoint given in current active schedule
  static IconData getManualModeIconData() {
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

  /// Saves given [value] to internal data map with identifier [key] 
  static void setSavedState(String key, dynamic value) {
    _savedStates[key] = value;
  }

  /// Returns the dynamic data saved with identifier [key]
  /// If the given [key] does not exist, returns [defaultValue]
  static dynamic getSavedState(String key, [dynamic defaultValue]) {
    if (_savedStates.containsKey(key)) {
      return _savedStates[key];
    }
    return defaultValue;
  }

  /// Removes the saved data associated with identifier [key]
  static void removeSavedState(String key) {
    if (_savedStates.containsKey(key)) {
      _savedStates.remove(key);
    }
  }

  /// Returns black or white to maximize contrast with given [backColor]
  static Color contrastColor(Color backColor) {
    if (backColor.computeLuminance() > 0.3) {
      return Colors.black;
    }
    return Colors.white;
  }

  /// Returns a new AppBar with given [title]
  /// A list of [actions] may be defined, each of them appearing as a circle icon button
  static AppBar createAppBar(String title, {List<Widget> actions = const []}) {
    return AppBar(
        title: Text(title),
        actions: actions +
            [
              Common.createCircleIcon(
                  size: 32,
                  icon: Icon(ModelCtrl().isConnectedToCtrlServer() ? Icons.link : Icons.link_off, color: Colors.white),
                  backColor: ModelCtrl().isConnectedToCtrlServer()
                      ? Colors.green.shade700
                      : ModelCtrl().isConnectedToMQTT()
                          ? Colors.orange.shade700
                          : Colors.red.shade800),
            ]);
  }

  /// Call this to navigate to a new page with given [route]
  /// The [route] must have been declared in current [NavbarRouter.destinations]
  static Future<void> navBarNavigate(BuildContext context, String route,
          {bool isDialog = false, bool isRootNavigator = true, Map<String, dynamic>? arguments}) =>
      Navigator.of(context, rootNavigator: isRootNavigator).pushNamed(route, arguments: arguments);

  /// Shows the snackbar with given [text]
  static void showSnackBar(BuildContext context, String text,
      {Color? backColor, Color? textColor, int durationMs = 2000}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: durationMs),
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

  /// Hides the snackbar if it is visible
  static void hideSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Returns the given [btnWidget] or null wether the server is currently connected or not
  /// Used to disable any global button dynamically in case server connection is not currently available
  static Widget? cnxStateButtonFilter(Widget btnWidget) {
    if (ModelCtrl().isConnectedToCtrlServer()) {
      return btnWidget;
    }
    return null;
  }

  /// Returns a filtered widget of given [scaffoldBody] to reflect the current 
  /// state of the server connexion.
  /// If the server is connected, [scaffoldBody] is returned
  /// If the server is not connected, a blur filter is applied to [scaffoldBody]
  static Widget cnxStateWidgetFilter(Widget scaffoldBody) {
    if (ModelCtrl().isConnectedToCtrlServer()) {
      return scaffoldBody;
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        scaffoldBody,
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 3.0,
            sigmaY: 3.0,
          ),
          child: Container(
            color: Colors.black.withOpacity(0),
          ),
        ),
        Center(child:
          Chip(
            padding: const EdgeInsets.all(10),
            backgroundColor: AppTheme().background2Color,
            side: BorderSide(color: AppTheme().warningColor),
            label: Text(wcLocalizations().popupWaitingConnection,
              style: TextStyle(
                color: AppTheme().warningColor),
              ),
          ),
        ),
      ],
    );
  }

  /// Creates a widget that can be used to tag an active schedule element
  /// It is currently a little red circle with contrasted border
  static Widget createActiveScheduleTag() {
    //return const Icon(Icons.circle, color: Colors.red, size:10);
    Decoration deco = BoxDecoration(
        color: Colors.red, shape: BoxShape.circle, border: Border.all(width: 2, color: AppTheme().background1Color));
    return Container(
      decoration: deco,
      width: 12,
      height: 12,
      alignment: Alignment.center,
    );
  }

  static Widget createCircleIcon({required Icon icon, required double size, required Color backColor}) {
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

  /// Floating buttons appears over the app bar to trigger an global action
  static Widget createFloatingButton(
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

  /// Builds and returns a [PopupMenuButton] that contains all items given in [menuItems].
  static Widget createPopupMenu(List<MyMenuItem> menuItems,
      {required void Function(dynamic) onSelected, Color? iconColor}) {
    return PopupMenuButton(
      color: AppTheme().background2Color,
      onSelected: onSelected,
      icon: Icon(Icons.more_vert, color: iconColor ?? AppTheme().focusColor),
      itemBuilder: (BuildContext bc) {
        return menuItems.map((MyMenuItem menuItem) {
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
      EdgeInsets? insetPadding,
      void Function()? onValidate}) async {
    await showDialog(
      context: context,
      builder: (context) {
        List<Widget> actions = [];
        switch (dlgButtons) {
          case DlgButtons.close:
            actions = [
              Common.createTextButton(
                wcLocalizations().closeAction,
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
                wcLocalizations().cancelAction,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Common.createTextButton(
                dlgButtons == DlgButtons.okCancel ? wcLocalizations().validateAction : wcLocalizations().continueAction,
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
            contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            insetPadding: insetPadding ?? const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            content: SingleChildScrollView(
              //shrinkWrap: true,
              child: content,
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: actions);
      },
    );
  }

  /// Shows a dialog that allows the user to select a list of devices.
  /// Devices shown are taken from current server configuration data.
  /// [filters] contains the list of devices initially selected
  static Future<void> pickDevices(BuildContext context, List<String> filters,
      {required void Function()? onValidate}) async {
    List<String> devices = ModelCtrl().getDevices().keys.toList();
    devices.sort();

    await showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: wcLocalizations().popupPickDeviceTitle,
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
    showModalDialog(context, dlgButtons: DlgButtons.close, title: wcLocalizations().popupErrorTitle,
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

  static Future<bool> showWarningDialog(BuildContext context, String alertText,
      {String title = '', bool closeBtnOnly = false}) async {
    bool result = false;

    final String defaultTitle = wcLocalizations().popupWarningTitle;
    if (title.isEmpty) {
      title = defaultTitle;
    }

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

  /// Allows the user to pick a color using the flutter_colorpicker package.
  /// Returns the chosen color, or the given [color] if user has click on cancel button.
  static Future<Color> showColorPicker(BuildContext context, Color color) async {
    Color result = color;

    await showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: wcLocalizations().popupPickColorTitle,
        onValidate: () => result = color,
        content: MaterialPicker(
          pickerColor: color,
          onColorChanged: (value) {
            color = value;
          },
        ));

    return result;
  }

  /// Shows the shedule properties dialog to allow the user to edit them.
  /// The currently only editable property is 'alias'.
  /// The given [data] map must contains the data of the schedule to edit.
  /// Given [onValidate] will be called on "Ok" button press,
  /// 'tapedName' parameter containing the new 'alias' value taped by the user. 
  static Future<void> editScheduleProperties(BuildContext context, Map data,
      void Function(BuildContext context, Map data, String tapedName) onValidate) async {
    var nameCtrl = TextEditingController(text: data['alias']);
    await showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: wcLocalizations().scheduleEditTitle,
        onValidate: () => onValidate(context, data, nameCtrl.text),
        content: Column(
          children: [
            Row(
              children: [
                Text('${wcLocalizations().scheduleEditName} : '),
                const SizedBox(width: 20),
                Flexible(
                    flex: 2,
                    child: TextFormField(
                      style: TextStyle(color: AppTheme().specialTextColor),
                      controller: nameCtrl,
                      decoration: InputDecoration(hintText: wcLocalizations().scheduleEditNameHint),
                    )),
              ],
            ),
          ],
        ));
  }

  /// Function used to sort devices the same way in all widgets that need to show a list of devices.
  /// The sort order if the order of declaration in server configuration.
  /// Returns <0 if [devName1] is the name of the first device appearing in server configuration data.
  /// Returns >0 if it is [devName2].
  /// Returns 0 if none of them has been found in current configuration
  static int compareDevicesOrder(String devName1, String devName2) {
    for (String key in ModelCtrl().getDevices().keys) {
      if (key == devName1) return -1;
      if (key == devName2) return 1;
    }
    return 0;
  }

  /// Allows the user to pick a schedule among all existing schedules in current configuration.
  /// [onValidate] will be called with the picked schedule alias as parameter.
  static Future<void> pickSchedule(BuildContext context, String defaultScheduleName,
      {required void Function(String selScheduleName)? onValidate}) async {
    String selectedAlias = defaultScheduleName;
    await showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: wcLocalizations().popupPickPlanningTitle,
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

  /// Shows the temperature set properties dialog to allow the user to edit them.
  /// The editable properties are 'alias' and 'iconColor'
  /// The given [data] map must contains the data of the schedule to edit.
  /// Given [onValidate] will be called on "Ok" button press,
  /// 'pickedColor' and 'tapedName' parameters containing the
  /// new 'iconColor' and 'alias' values taped by the user. 
  static Future<void> editTemperatureSetProperties(BuildContext context, Map data, String scheduleName,
      void Function(Map data, String scheduleName, Color pickedColor, String tapedName) onValidate) async {
    var nameCtrl = TextEditingController(text: data['alias']);
    Color color = Color(ModelCtrl.getGUIParamHex(data, 'iconColor', Settings().temperatureSetDefaultColor));
    await showModalDialog(context,
        dlgButtons: DlgButtons.okCancel,
        title: wcLocalizations().tempSetEditTitle,
        onValidate: () => onValidate(data, scheduleName, color, nameCtrl.text),
        content: StatefulBuilder(builder: (context, setState) {
          return Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('${wcLocalizations().tempSetEditName} : '),
                  const SizedBox(width: 20),
                  Flexible(
                      flex: 2,
                      child: TextFormField(
                        style: TextStyle(color: AppTheme().specialTextColor),
                        controller: nameCtrl,
                        decoration: InputDecoration(hintText: wcLocalizations().tempSetEditNameHint),
                      )),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(child: SizedBox(height: 30.0, child: Text('${wcLocalizations().tempSetEditColor} : '))),
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
              ),
            ],
          );
        }));
  }

  /// Due to a flutter bug, the padding, for any chip widget, depends on the target platform
  /// This function intends to Wrap a chip into a padding that takes into account this bug.
  static Widget wrapChip(Widget chip) {
    return Padding(
        padding: EdgeInsets.only(
            bottom: PlatformDetails().isDesktop ? 8.0 : 0.0, top: PlatformDetails().isDesktop ? 8.0 : 0.0),
        child: chip);
  }

  /// Creates a [Chip] row of selectable week days
  static Widget createWeekChips(String scheduleName, int scheduleItemIdx, int timeslotSetIdx, Map timeslotSetData,
      {bool passiveMode = false}) {
    var list = [
      ['1', wcLocalizations().weekChipMonday],
      ['2', wcLocalizations().weekChipTuesday],
      ['3', wcLocalizations().weekChipWednesday],
      ['4', wcLocalizations().weekChipThurday],
      ['5', wcLocalizations().weekChipFriday],
      ['6', wcLocalizations().weekChipSaturday],
      ['7', wcLocalizations().weekChipSunday]
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

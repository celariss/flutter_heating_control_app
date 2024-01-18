import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

import '../../common/common.dart';
import '../../common/model_ctrl.dart';
import '../../common/settings.dart';
import '../../common/theme.dart';
import '../../utils/localizations.dart';

class TemperatureSet {
  static Widget temperatureSetTileBuilder(BuildContext context, Map tempSetData, String scheduleName,
      {bool dense = false, Color? titleColor}) {
    List<Map> devicesList = (tempSetData['devices'] as List).map((e) => e as Map).toList();
    devicesList.sort((a, b) => Common.compareDevicesOrder(a['device_name'], b['device_name']));

    Color tempSetColor = Color(ModelCtrl.getGUIParamHex(tempSetData, 'iconColor', 0xFF000000));
    double fontSize = dense ? Common.getRadioListTextSize() : Common.getListViewTextSize();

    Widget leading = Container(
      width: 30.0,
      height: 30.0,
      decoration: BoxDecoration(
        color: tempSetColor,
        shape: BoxShape.circle,
      ),
      child: Icon(Common.getTempSetIconData(), color: Common.contrastColor(tempSetColor)),
    );

    bool isExpanded = Common.getSavedState('tempSetLV${scheduleName}_${tempSetData['alias']}', false) as bool;

    Widget title = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(tempSetData['alias'],
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: titleColor
                        )
                ),
              ]),
            ] +
            ((dense == true)
                ? []
                : [
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      _temperatureSetMenuBuilder(context, tempSetData, scheduleName),
                    ]),
                  ]));

    if (dense) {
      return Row(
        children: [leading, const SizedBox(width: 10), title],
      );
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

    return StatefulBuilder(
      key: Key(tempSetData['alias']),
      builder: (BuildContext context, setState) {
        Widget title_ = title;
        return ExpansionTile(
          textColor: AppTheme().focusColor,
          collapsedTextColor: AppTheme().specialTextColor,
          iconColor: AppTheme().focusColor,
          collapsedIconColor: AppTheme().specialTextColor,
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            Common.setSavedState('tempSetLV${scheduleName}_${tempSetData['alias']}', expanded);
            setState(() {
              isExpanded = expanded;
            });
          },
          tilePadding: EdgeInsets.fromLTRB(0, 0, rightPadding, 0),
          leading: leading,
          title: title_,
          children: devicesList.map((dev) => _buildDeviceTile(context, dev, scheduleName)).toList(),
        );
      },
    );
  }

  static Widget _temperatureSetMenuBuilder(BuildContext context, Map tempSetData, String scheduleName) {
    return Common.createPopupMenu(
      [
        MyMenuItem(Icons.edit, wcLocalizations().editAction(''), 'edit_properties'),
        MyMenuItem(Common.getDeviceIconData(), wcLocalizations().editAction('eqptlist'), 'change_devices'),
        MyMenuItem(Icons.copy, wcLocalizations().cloneAction, 'clone'),
        MyMenuItem(Icons.cancel_outlined, wcLocalizations().removeAction, 'delete')
      ],
      onSelected: (itemValue) async {
        switch (itemValue) {
          case 'edit_properties':
            Common.editTemperatureSetProperties(
                context, tempSetData, scheduleName, _onTemperatureSetPropertiesValidate);
            break;

          case 'change_devices':
            List<String> filters = (tempSetData['devices'] as List).map((e) => e['device_name'] as String).toList();
            Common.pickDevices(
              context,
              filters,
              onValidate: () {
                List<Map> newDevicesList = [];
                for (String filter in filters) {
                  Map tsDevice = _findDeviceInTemperatureSet(tempSetData, filter);
                  if (tsDevice.isNotEmpty) {
                    newDevicesList.add(tsDevice);
                  } else {
                    newDevicesList.add({'device_name': filter, 'setpoint': Settings().defaultSetpoint});
                  }
                }
                tempSetData['devices'] = newDevicesList;
                ModelCtrl().onTemperatureSetsChanged(scheduleName);
              },
            );
            break;

          case 'clone':
            Map tempSetData_ = ModelCtrl.cloneMap(tempSetData);
            tempSetData_['alias'] = ModelCtrl().createAvailableTempSetName(tempSetData['alias']);
            Common.editTemperatureSetProperties(
              context,
              tempSetData_,
              '',
              (data, scheduleName, pickedColor, tapedName) {
                tempSetData_['alias'] = ModelCtrl().createAvailableTempSetName(tapedName);
                ModelCtrl().createTemperatureSet(pickedColor.value, tapedName,
                    scheduleName: scheduleName, newTempSetData: tempSetData_);
              },
            );
            break;

          case 'delete':
            bool result = await Common.showWarningDialog(
                context, wcLocalizations().removeConfirmation('tempset', tempSetData['alias']));
            if (result) {
              ModelCtrl().deleteTemperatureSet(tempSetData['alias'], scheduleName);
            }
            break;
        }
      },
    );
  }

  static Widget _buildDeviceTile(BuildContext context, Map data, String scheduleName) {
    double rightPadding = 0;
    switch (Theme.of(context).platform) {
        case TargetPlatform.linux:
        case TargetPlatform.windows:
        case TargetPlatform.macOS:
          rightPadding = 30;
          break;
        default:
    }
    //return Builder(builder: (context) {
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListTile(
          onTap: () {
            /*NavbarNotifier.hideBottomNavBar = false;
                  navigate(context, ProductComments.route,
                      isRootNavigator: false,
                      arguments: {'id': argsId.toString()});*/
            _showTemperaturePicker(context, data['setpoint'].toDouble(), Settings().minSetpoint, Settings().maxSetpoint).then((value) {
              //setState(() => data['setpoint'] = value);
              if (data['setpoint'] != value) {
                data['setpoint'] = value;
                ModelCtrl().onTemperatureSetsChanged(scheduleName);
              }
            });
          },
          contentPadding: EdgeInsets.fromLTRB(50, 0, rightPadding, 0),
          visualDensity: VisualDensity.compact,
          horizontalTitleGap: 10,
          leading: Icon(Common.getDeviceIconData(), color: AppTheme().specialTextColor), //SizedBox(),
          title: Text(data['device_name'], style:TextStyle(color: AppTheme().normalTextColor)),
          trailing: Text('${data['setpoint'].toStringAsFixed(1)}°',
              style: TextStyle(fontSize: 16, color: AppTheme().focusColor, fontWeight: FontWeight.bold)),
        ),
      );
    });
  }

  static Future<double> _showTemperaturePicker(BuildContext context, double temperature, int min, int max) async {
    double result = temperature;
    if (temperature < min) {
      temperature = min.toDouble();
    }
    if (temperature > max) {
      temperature = max.toDouble();
    }
    int intValue = temperature.toInt();
    int decValue = (temperature * 10.0).toInt() % 10;
    List<int> intList = List<int>.generate(max - min+1, (i) => i + min);
    List<int> decList = List<int>.generate(10, (i) => i);
    await Picker(
        adapter: PickerDataAdapter<String>(pickerData: [intList, decList], isArray: true),
        selecteds: [intValue - min, decValue],
        hideHeader: true,
        cancelText: wcLocalizations().cancelAction,
        confirmText: wcLocalizations().validateAction,
        cancelTextStyle: TextStyle(color: AppTheme().buttonTextColor),
        confirmTextStyle: TextStyle(color: AppTheme().buttonTextColor),
        backgroundColor: AppTheme().background2Color,
        textStyle: TextStyle(color: AppTheme().specialTextColor, fontSize: 18),
        selectedTextStyle: TextStyle(color: AppTheme().normalTextColor, fontSize: 22),
        //title: new Text("Please Select"),
        onConfirm: (Picker picker, List value) {
          result = intList[value[0]].toDouble() + value[1].toDouble() / 10;
          if (result > max) {
            result = max.toDouble();
          }
        }).showDialog(context, backgroundColor: AppTheme().background2Color);
    return result;
  }

  static _onTemperatureSetPropertiesValidate(Map data, String scheduleName, Color pickedColor, String tapedName) {
    int oldColor = ModelCtrl.getGUIParamHex(data, 'iconColor', Settings().temperatureSetDefaultColor);
    if (oldColor != pickedColor.value) {
      ModelCtrl.setGUIParamHex(data, 'iconColor', pickedColor.value);
      ModelCtrl().onTemperatureSetsChanged(scheduleName);
    }
    if (data['alias'] != tapedName) {
      bool isExpanded = Common.getSavedState('tempSetLV${scheduleName}_${data['alias']}', false) as bool;
      Common.removeSavedState('tempSetLV${scheduleName}_${data['alias']}');
      Common.setSavedState('tempSetLV${scheduleName}_$tapedName', isExpanded);
      ModelCtrl().onTemperatureSetNameChanged(scheduleName, data['alias'], tapedName);
    }
  }

  static Map _findDeviceInTemperatureSet(Map tempSetData, String deviceName) {
    for (Map device in tempSetData['devices']) {
      if (device['device_name'] == deviceName) {
        return device;
      }
    }
    return {};
  }
}

/// This file defines a helper to manage themes
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AppTheme {
  static final AppTheme _instance = AppTheme._internal();
  AppTheme._internal();
  factory AppTheme() {
    return _instance;
  }

  void loadFromMap(Map data) {
    background1Color = string2Color(data['background1Color']);
    background2Color = string2Color(data['background2Color']);
    background3Color = string2Color(data['background3Color']);
    normalTextColor = string2Color(data['normalTextColor']);
    specialTextColor = string2Color(data['specialTextColor']);
    appBarColor = string2Color(data['appBarColor']);
    appBarTextColor = string2Color(data['appBarTextColor']);
    focusColor = string2Color(data['focusColor']);
    heaterWidgetTrackColor = string2Color(data['heaterWidgetTrackColor']);
    heaterWidgetNoScheduleStateColor = string2Color(data['heaterWidgetNoScheduleStateColor']);
    heaterWidgetAutoStateColor = string2Color(data['heaterWidgetAutoStateColor']);
    heaterWidgetManuelStateColor = string2Color(data['heaterWidgetManuelStateColor']);
    heaterWidgetPendingStateColor = string2Color(data['heaterWidgetPendingStateColor']);
    heaterWidgetTitleColor = string2Color(data['heaterWidgetTitleColor']);
    buttonTextColor = string2Color(data['buttonTextColor']);
    warningColor = string2Color(data['warningColor']);
    errorColor = string2Color(data['errorColor']);
    successColor = string2Color(data['successColor']);
  }

  static String color2String(Color color) {
    return '0x${color.toHexString()}';
  }

  static Color string2Color(String colorStr, [Color defaultValue = Colors.black]) {
    int? value;
    if (colorStr.startsWith('0x')) {
      value = int.tryParse(colorStr.substring(2), radix: 16);
    } else {
      value = int.tryParse(colorStr, radix: 10);
    }
    if (value != null) {
      return Color(value);
    }
    return defaultValue;
  }

  Map saveToMap() {
    Map map = {
      'background1Color':color2String(background1Color),
      'background2Color':color2String(background2Color),
      'background3Color':color2String(background3Color),
      'normalTextColor':color2String(normalTextColor),
      'specialTextColor':color2String(specialTextColor),
      'appBarColor':color2String(appBarColor),
      'appBarTextColor':color2String(appBarTextColor),
      'focusColor':color2String(focusColor),
      'heaterWidgetTrackColor':color2String(heaterWidgetTrackColor),
      'heaterWidgetNoScheduleStateColor':color2String(heaterWidgetNoScheduleStateColor),
      'heaterWidgetAutoStateColor':color2String(heaterWidgetAutoStateColor),
      'heaterWidgetManuelStateColor':color2String(heaterWidgetManuelStateColor),
      'heaterWidgetPendingStateColor':color2String(heaterWidgetPendingStateColor),
      'heaterWidgetTitleColor':color2String(heaterWidgetTitleColor),
      'buttonTextColor':color2String(buttonTextColor),
      'warningColor':color2String(warningColor),
      'errorColor':color2String(errorColor),
      'successColor':color2String(successColor),
    };
    return map;
  }

  double defaultElevation = 8;

  Color background1Color = Colors.grey.shade100;

  Color background2Color = Colors.grey.shade300;

  Color background3Color = Colors.grey.shade400;

  Color normalTextColor = Colors.black;

  Color specialTextColor = Colors.grey.shade800;

  Color appBarColor = Colors.indigo.shade800;

  Color appBarTextColor = Colors.white;

  // Color for :
  //  - Special text
  Color focusColor = Colors.blue.shade900;

  Color heaterWidgetTrackColor = Colors.black;

  Color heaterWidgetNoScheduleStateColor = Colors.black;

  Color heaterWidgetAutoStateColor = Colors.blue.shade900;

  Color heaterWidgetManuelStateColor = Colors.deepOrange.shade900;

  Color heaterWidgetPendingStateColor = Colors.grey;

  Color heaterWidgetTitleColor = Colors.purple.shade800;

  /////////////////////////////////////////////////////////
  Color buttonTextColor = Colors.white;

  Color warningColor = Colors.orange.shade600;

  Color errorColor = Colors.red.shade800;

  Color successColor = Colors.green.shade700;
}

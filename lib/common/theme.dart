/// This file defines a helper to manage themes
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library theme_helpers;

import 'package:flutter/material.dart';

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
    focusColor = string2Color(data['focusColor']);
    heaterWidgetTrackColor = string2Color(data['heaterWidgetTrackColor']);
    heaterWidgetNoScheduleStateColor = string2Color(data['heaterWidgetNoScheduleStateColor']);
    heaterWidgetAutoStateColor = string2Color(data['heaterWidgetAutoStateColor']);
    heaterWidgetManuelStateColor = string2Color(data['heaterWidgetManuelStateColor']);
    heaterWidgetPendingStateColor = string2Color(data['heaterWidgetPendingStateColor']);
    heaterWidgetTitleColor = string2Color(data['heaterWidgetTitleColor']);
    buttonBackColor = string2Color(data['buttonBackColor']);
    buttonTextColor = string2Color(data['buttonTextColor']);
    selectedColor = string2Color(data['selectedColor']);
    notSelectedColor = string2Color(data['notSelectedColor']);
    warningColor = string2Color(data['warningColor']);
    errorColor = string2Color(data['errorColor']);
    successColor = string2Color(data['successColor']);
  }

  static String color2String(Color color) {
    return '0x${color.value.toRadixString(16).toUpperCase()}';
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
      'focusColor':color2String(focusColor),
      'heaterWidgetTrackColor':color2String(heaterWidgetTrackColor),
      'heaterWidgetNoScheduleStateColor':color2String(heaterWidgetNoScheduleStateColor),
      'heaterWidgetAutoStateColor':color2String(heaterWidgetAutoStateColor),
      'heaterWidgetManuelStateColor':color2String(heaterWidgetManuelStateColor),
      'heaterWidgetPendingStateColor':color2String(heaterWidgetPendingStateColor),
      'heaterWidgetTitleColor':color2String(heaterWidgetTitleColor),
      'buttonBackColor':color2String(buttonBackColor),
      'buttonTextColor':color2String(buttonTextColor),
      'selectedColor':color2String(selectedColor),
      'notSelectedColor':color2String(notSelectedColor),
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
  Color buttonBackColor = Colors.blue.shade900;

  Color buttonTextColor = Colors.white;

  Color selectedColor = Colors.lightGreen.shade600;

  Color notSelectedColor = Colors.grey.shade400;

  Color warningColor = Colors.orange.shade600;

  Color errorColor = Colors.red.shade800;

  Color successColor = Colors.green.shade700;
}

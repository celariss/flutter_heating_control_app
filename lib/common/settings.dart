/// Contains the class that loads the app settings from files
/// in folder ./assets/cfg/
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause

import 'package:flutter/material.dart';
import '../utils/configuration.dart';
import 'mqtt_settings.dart';
import 'theme.dart';

class Settings {
  static final Settings _instance = Settings._internal();
  Settings._internal();
  factory Settings() {
    return _instance;
  }

  Future<void> loadConfigFile({BuildContext? context}) async {
    if (!_initDone) {
      Configuration config = Configuration();
      await config.addFromAsset('assets/cfg/config.yaml', context: context);
      await config.addFromAsset('assets/cfg/secrets.yaml', context: context);
      await config.addFromAsset('assets/cfg/themes.yaml', context: context);
      MQTT = MQTTSettings.fromMap(config.getSection('mqtt'));
      temperatureSetDefaultColor = _string2Int(config.getValue('temperatureSetDefaultColor'), 0xFF000000);
      defaultSetpoint = _string2double(config.getValue('defaultSetpoint'), 19.0);
      themeName = config.getValue('themeName', '');
      List themes = config.getValue('themes', []);
      for (Map theme in themes) {
        if (theme.containsKey('name') && theme['name']==themeName) {
          AppTheme().loadFromMap(theme);
          break;
        }
      }
      _initDone = true;
    }
  }

  MQTTSettings MQTT = MQTTSettings();
  int temperatureSetDefaultColor = 0;
  double defaultSetpoint = 0;
  String themeName = '';

  bool _initDone = false;

  static int _string2Int(dynamic str, [int defaultValue = 0]) {
    if (str is int) {
      return str;
    }
    int? value;
    if (str is String) {
      if (str.startsWith('0x')) {
        value = int.tryParse(str.substring(2), radix: 16);
      } else {
        value = int.tryParse(str, radix: 10);
      }
      if (value != null) {
        return value;
      }
    }
    return defaultValue;
  }

  static double _string2double(dynamic str, [double defaultValue = 0.0]) {
    if (str is double) {
      return str;
    }
    if (str is int) {
      return str.toDouble();
    }
    double? value;
    if (str is String) {
      value = double.tryParse(str);
      if (value != null) {
        return value;
      }
    }
    return defaultValue;
  }
}

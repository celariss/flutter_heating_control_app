/// Contains the class that loads the app settings from files
/// in folder ./assets/cfg/
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause

import 'package:flutter/material.dart';
import '../utils/configuration.dart';
import 'mqtt_settings.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static final Settings _instance = Settings._internal();
  Settings._internal();
  factory Settings() {
    return _instance;
  }
  SharedPreferences ?prefs;

  Future<void> loadConfigFile({BuildContext? context}) async {
    if (!_initDone) {
      prefs = await SharedPreferences.getInstance();
      Configuration config = Configuration();
      await config.addFromAsset('assets/cfg/config.yaml', context: context);
      await config.addFromAsset('assets/cfg/secrets.yaml', context: context);
      await config.addFromAsset('assets/cfg/themes.yaml', context: context);
      Map mqtt = config.getSection('mqtt');
      for (String param in mqtt.keys) {
        if (prefs!.containsKey(param)) {
          mqtt[param] = prefs!.get(param) ?? mqtt[param];
        }
      }
      MQTT = MQTTSettings.fromMap(mqtt);
      temperatureSetDefaultColor = _getParamInt(config, 'temperatureSetDefaultColor', 0xFF000000);
      defaultSetpoint = _getParamDouble(config, 'defaultSetpoint', 19.0);
      minSetpoint = _getParamInt(config, 'minSetpoint', 7);
      maxSetpoint = _getParamInt(config, 'maxSetpoint', 30);
      themeName = _getParam(config, 'themeName', '');
      _themes = _getParam(config, 'themes', []);
      setTheme(themeName);
      _initDone = true;
    }
  }

  List<String> getThemesList() {
    return _themes.map((theme) => theme['name'] as String).toList();
  }

  void setTheme(String name) {
    themeName = name;
    for (Map theme in _themes) {
      if (theme.containsKey('name') && theme['name']==themeName) {
        AppTheme().loadFromMap(theme);
        prefs!.setString('themeName', name);
        break;
      }
    }
  }

  void setMqttUrl(String value) {
    MQTT.brokerAddress = value;
    MQTT.saveToSharedPrefs();
  }

  void setMqttUser(String value) {
    MQTT.user = value;
    MQTT.saveToSharedPrefs();
  }

  void setMqttPassword(String value) {
    MQTT.password = value;
    MQTT.saveToSharedPrefs();
  }

  MQTTSettings MQTT = MQTTSettings();
  int temperatureSetDefaultColor = 0;
  double defaultSetpoint = 0;
  int minSetpoint = 0;
  int maxSetpoint = 0;
  String themeName = '';

  bool _initDone = false;
  List _themes = [];

  dynamic _getParam(Configuration config, dynamic paramName, [dynamic defaultValue]) {
    if (prefs!.containsKey(paramName)) {
      return prefs!.get(paramName) ?? defaultValue;
    }
    return config.getValue(paramName, defaultValue);
  }

  int _getParamInt(Configuration config, dynamic paramName, [int defaultValue = 0]) {
    if (prefs!.containsKey(paramName)) {
      return prefs!.getInt(paramName) ?? defaultValue;
    }
    return _string2Int(config.getValue(paramName), defaultValue);
  }

  double _getParamDouble(Configuration config, dynamic paramName, [double defaultValue = 0.0]) {
    if (prefs!.containsKey(paramName)) {
      return prefs!.getDouble(paramName) ?? defaultValue;
    }
    return _string2double(config.getValue(paramName), defaultValue);
  }

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

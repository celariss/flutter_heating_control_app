/// Contains the class that loads the app settings from files
/// in folder ./assets/cfg/
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heating_control_app/utils/localizations.dart';
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
      // ignore: use_build_context_synchronously
      await config.addFromAsset('assets/cfg/config.yaml', context: context);
      // ignore: use_build_context_synchronously
      await config.addFromAsset('assets/cfg/secrets.yaml', context: context);
      // ignore: use_build_context_synchronously
      await config.addFromAsset('assets/cfg/themes.yaml', context: context);

      Map mqtt = config.getSection('mqtt');
      MQTT = MQTTSettings.fromMap(mqtt);
      await MQTT.readFromSharedPrefs();
      MQTT.saveToSharedPrefs();

      temperatureSetDefaultColor = _getParamInt(config, 'temperatureSetDefaultColor', 0xFF000000);
      defaultSetpoint = _getParamDouble(config, 'defaultSetpoint', 19.0);
      minSetpoint = _getParamInt(config, 'minSetpoint', 7);
      maxSetpoint = _getParamInt(config, 'maxSetpoint', 30);
      thermostatResolution = _getParamDouble(config, 'thermostatResolution', 0.5);
      String strLocale = _getParam(config, 'locale', '');
      if (strLocale=='') {
        locale = null;
      } else {
        locale = tryParseLocale(strLocale);
      }
      themeName = _getParam(config, 'themeName', '');
      final savedThemes = prefs!.getString('themes');
      if (savedThemes != null) {
        _themes = (jsonDecode(savedThemes) as List)
            .map((theme) => Map<String, dynamic>.from(theme as Map))
            .toList();
      } else {
        _themes = _getParam(config, 'themes', []);
      }
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

  Map<String, dynamic>? getThemeData(String name) {
    for (final theme in _themes) {
      if (theme is Map && theme['name'] == name) {
        return Map<String, dynamic>.from(theme);
      }
    }
    return null;
  }

  bool createTheme(String name, {String? templateName}) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty || getThemesList().contains(normalizedName)) {
      return false;
    }

    final source = getThemeData(templateName ?? themeName) ??
        (_themes.isNotEmpty
            ? Map<String, dynamic>.from(_themes.first)
            : AppTheme().saveToMap());
    source['name'] = normalizedName;
    _themes.add(source);
    _saveThemes();
    return true;
  }

  bool updateThemeColor(String name, String colorName, Color color) {
    final themes = _themes.cast<Map>().where((item) => item['name'] == name);
    if (themes.isEmpty || !AppTheme().saveToMap().containsKey(colorName)) {
      return false;
    }

    final selectedTheme = themes.first;
    selectedTheme[colorName] = AppTheme.color2String(color);
    if (themeName == name) {
      AppTheme().loadFromMap(selectedTheme);
    }
    _saveThemes();
    return true;
  }

  bool deleteTheme(String name) {
    if (_themes.length <= 1) {
      return false;
    }
    _themes.removeWhere((theme) => theme is Map && theme['name'] == name);
    _saveThemes();
    if (themeName == name) {
      setTheme(_themes.first['name'] as String);
    }
    return true;
  }

  void _saveThemes() {
    prefs!.setString('themes', jsonEncode(_themes));
  }

  void setMqttUrl(String value) {
    MQTT.brokerAddress = value.trim();
    MQTT.saveToSharedPrefs();
  }

  void setMqttUser(String value) {
    MQTT.user = value.trim();
    MQTT.saveToSharedPrefs();
  }

  void setMqttPort(int value) {
    MQTT.port = value;
    MQTT.saveToSharedPrefs();
  }

  void setMqttSecure(bool value) {
    MQTT.secure = value;
    MQTT.saveToSharedPrefs();
  }

  void setMqttPassword(String value) {
    MQTT.password = value;
    MQTT.saveToSharedPrefs();
  }

  void setThermostatResolution(double value) {
    thermostatResolution = value;
    prefs!.setDouble('thermostatResolution', thermostatResolution);
  }

  // give null to go back to system locale
  void setLocale(Locale ?newLocale) {
    String strLocale = '';
    locale = null;
    if (newLocale!=null) {
      strLocale = newLocale.toLanguageTag();
      locale = newLocale;
    }
    prefs!.setString('locale', strLocale);
  }

  // ignore: non_constant_identifier_names
  MQTTSettings MQTT = MQTTSettings();
  int temperatureSetDefaultColor = 0;
  double defaultSetpoint = 0;
  int minSetpoint = 0;
  int maxSetpoint = 0;
  double thermostatResolution = 0;
  String themeName = '';
  Locale ?locale;

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

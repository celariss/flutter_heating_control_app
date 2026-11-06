/// This file defines a Helper to load yaml/json configuration files
/// 
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'convert.dart';

enum FileType {
  invalid,
  json,
  yaml,
}

class Configuration {
  Map configMap_ = {};

  dynamic getSection(String sectionName) {
    if (configMap_.containsKey(sectionName)) {
      return configMap_[sectionName];
    }
    return null;
  }

  // ${valuePath} is a path inside the current configuration map
  // for example : 'global_section/timeout'
  dynamic getValue(String valuePath, [dynamic defaultValue]) {
    List<String> items = valuePath.split('/');
    Map target = configMap_;
    for (int i = 0; i < items.length; i++) {
      String key = items[i];
      if (!target.containsKey(key)) {
        return defaultValue;
      }
      if (i == items.length - 1) {
        return target[key];
      }
      if (target[key] is! Map) {
        return defaultValue;
      }
      target = target[key];
    }
    return defaultValue;
  }

  void addFromMap(Map map, {String? targetSection}) {
    Map target = configMap_;
    if (targetSection != null) {
      if (!configMap_.containsKey(targetSection)) {
        configMap_[targetSection] = {};
      }
      target = configMap_[targetSection];
    }
    _mergeMaps(target, map);
  }

  // Don't forget to add ${path} to pubspec.yaml :
  //   flutter:
  //     assets:
  //       - assets/my_config.yaml
  //
  // ${path} is relative to assets folder.
  // ${path} can be a yaml or json file (and must have adequate file extension).
  Future<bool> addFromAsset(String path, {BuildContext ?context, String? targetSection}) async {
    FileType type = getFileType(path);
    if (type == FileType.invalid) {
      return false;
    }
    AssetBundle bundle = rootBundle;
    if (context!=null) {
      bundle = DefaultAssetBundle.of(context);
    }
    String content;
    try {
      content = await bundle.loadString(path);
    } on FlutterError {
      return false;
    }
    switch (type) {
      case FileType.yaml:
        addFromYamlString(content, targetSection: targetSection);
        break;
      case FileType.json:
        addFromJsonString(content, targetSection: targetSection);
        break;
      default:
        return false;
    }
    return true;
  }

  // ${path} can be a yaml or json file (and must have adequate file extension).
  Future<bool> addFromFile(String path, {String? targetSection}) async {
    FileType type = getFileType(path);
    if (type == FileType.invalid) {
      return false;
    }
    File configFile = File(path);
    String content = await configFile.readAsString();
    switch (type) {
      case FileType.yaml:
        addFromYamlString(content, targetSection: targetSection);
        break;
      case FileType.json:
        addFromJsonString(content, targetSection: targetSection);
        break;
      default:
    }
    return true;
  }

  Future<void> addFromSharedPreferences({String? srcKey, String? targetSection}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (srcKey != null) {
      Object? value = prefs.get(srcKey);
      if (value != null) {
        if (value is String) {
          if (_isJsonValid(value)) {
            addFromJsonString(value, targetSection: targetSection);
          } else {
            configMap_[targetSection ?? srcKey] = value;
          }
        } else if (value is Map) {
          addFromMap(value, targetSection: targetSection);
        } else if (value is List) {
          addFromMap({(targetSection ?? srcKey): value}, targetSection: targetSection);
        }
      }
    } else {
      Map map = {};
      for (String key in prefs.getKeys()) {
        map[key] = prefs.get(key);
      }
      addFromMap(map, targetSection: targetSection);
    }
  }

  Future<void> addFromFlutterSecureStorage(FlutterSecureStorage storage, {String? targetSection}) async {
    Map map = {};
    Map<String, String> allValues = await storage.readAll();
    for (String key in allValues.keys) {
      map[key] = _jsonDecode(allValues[key]);
    }
    addFromMap(map, targetSection: targetSection);
  }

  void addFromYamlString(String yamlString, {String? targetSection}) {
    dynamic map = loadYaml(yamlString);
    addFromMap(YamlMapConverter.toMap(map), targetSection: targetSection);
  }

  void addFromJsonString(String jsonString, {String? targetSection}) {
    try {
      dynamic object = jsonDecode(jsonString);
      if (object is Map) {
        addFromMap(object, targetSection: targetSection);
      } else if (object is List) {
        addFromMap({(targetSection!=null ? targetSection.toString() : 'list'): object});
      }
    } catch (e) {
      // catch Json parsing error
    }
  }

  static FileType getFileType(String path) {
    String extension = p.extension(path).toLowerCase();
    switch (extension) {
      case '.json':
        return FileType.json;
      case '.yaml':
        return FileType.yaml;
      default:
        return FileType.invalid;
    }
  }

  static void _mergeMaps(Map target, Map source) {
    for (String key in source.keys) {
      dynamic sourceItem = source[key];
      if (target.containsKey(key)) {
        dynamic targetItem = target[key];
        if (targetItem is List) {
          if (sourceItem is List) {
            targetItem.addAll(sourceItem);
          } else {
            // TBD : ERROR
          }
        } else if (targetItem is Map) {
          if (sourceItem is Map) {
            _mergeMaps(targetItem, sourceItem);
          } else {
            // TBD : ERROR
          }
        } else {
          target[key] = source[key];
        }
      } else {
        target[key] = source[key];
      }
    }
  }

  static bool _isJsonValid(String source) {
    try {
      final parsed = jsonDecode(source);
      return parsed is Map<String, dynamic> || parsed is List;
    } catch (e) {
      return false;
    }
  }

  static dynamic _jsonDecode(String? value) {
    if (value != null) {
      try {
        final parsed = jsonDecode(value);
        return parsed;
      } catch (e) {
        // catch Json parsing error
      }
    }
    return value;
  }
}
/// This file defines a Helper to load yaml/json configuration files
/// 
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause


import 'dart:io';
import 'dart:convert';
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
    mergeMaps_(target, map);
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
    String content = await bundle.loadString(path);
    switch (type) {
      case FileType.yaml:
        addFromYamlString(content, targetSection: targetSection);
        break;
      case FileType.json:
        addFromJsonString(content, targetSection: targetSection);
        break;
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
    }
    return true;
  }

  void addFromYamlString(String yamlString, {String? targetSection}) {
    dynamic map = loadYaml(yamlString);
    addFromMap(YamlMapConverter.toMap(map), targetSection: targetSection);
  }

  void addFromJsonString(String jsonString, {String? targetSection}) {
    dynamic map = jsonDecode(jsonString);
    addFromMap(map, targetSection: targetSection);
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

  static void mergeMaps_(Map target, Map source) {
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
            mergeMaps_(targetItem, sourceItem);
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
}

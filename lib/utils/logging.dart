import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum Level {
  debug, info, warn, error, fatal;
  @override
  String toString() {
    switch (index) {
      case 0: return "DEBUG";
      case 1: return "INFO ";
      case 2: return "WARN ";
      case 3: return "ERROR";
      case 4:
      default:
        return "FATAL";
    }
  }
  }

class Logging {
  /// hierarchical name like "myApp.myClass". may be simply "myClass"
  static Logger getLogger([String hierarchicalName = '', Level ?level]) {
    if (hierarchicalName=='') {
      hierarchicalName = 'root';
    }
    if (!_loggerMap.containsKey(hierarchicalName)) {
      _loggerMap[hierarchicalName] = Logger(hierarchicalName, (level != null)?level:(kDebugMode)?Level.debug:Level.info);
    }
    return _loggerMap[hierarchicalName]!;
  }

  /////////////////////////////////////////////////////////
  ///  PRIVATE FIELDS
  /////////////////////////////////////////////////////////
  static final Map<String, Logger> _loggerMap = <String, Logger>{};
}

class Logger {
  Logger(String name,Level level) : _name = name, _level = level;

  void setLevel(Level level) {
    _level = level;
  }

  void log(Level level, String text) {
    if (level.index >= _level.index) {
      dev.log(_formatter.format(_name, level, text, DateTime.now()));
    }
  }

  void debug(String text) {
    log(Level.debug, text);
  }

  void info(String text) {
    log(Level.info, text);
  }

  void warn(String text) {
    log(Level.debug, text);
  }

  void error(String text) {
    log(Level.error, text);
  }

  void fatal(String text) {
    log(Level.fatal, text);
  }

  /////////////////////////////////////////////////////////
  ///  PRIVATE FIELDS
  /////////////////////////////////////////////////////////
  final String _name;
  Level _level;
  final Formatter _formatter = Formatter();
}

class Formatter {
  /// See DateFormat class for more info about format
  /// (https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html)
  Formatter({String dateFormat = 'yyyy-MM-dd HH:mm:ss'}) :
    _formatter = DateFormat(dateFormat);

  String format(String loggerName, Level level, String text, DateTime date) {
    return "${formatTime(date)} [${level.toString()}] $loggerName: $text";
  }

  String formatTime(DateTime date) {
    return _formatter.format(date);
  }

  /////////////////////////////////////////////////////////
  ///  PRIVATE FIELDS
  /////////////////////////////////////////////////////////
  final DateFormat _formatter;
}
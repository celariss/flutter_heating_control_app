/// This file defines helpers to manipulate times from model
/// Note: A model time is a list of 3 integers [hh, mm, ss]
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library timetool;

import 'dart:math';

/// TBD : to be used to replace List<int> in time manipulations
class HSTime {
  final List<int> _time;
  HSTime(int hour, int min, int sec) : _time = [hour, min, sec];
  //int operator [](int index) => _time[min(3,max(0,index))];
  void operator []=(int index, int value) {
    _time[min(3, max(0, index))] = value;
  }

  int get hour => _time[0];
  int get minute => _time[1];
  int get second => _time[2];
}

class TimeTool {
  static List<int>? parseTimeStr(String timeStr) {
    final RegExp re = RegExp(r'^(\d\d):(\d\d):(\d\d)$');
    RegExpMatch? match = re.firstMatch(timeStr);
    if (match != null && match.groupCount == 3) {
      int hours = int.parse(match[1] ?? '');
      int min = int.parse(match[2] ?? '');
      int sec = int.parse(match[3] ?? '');
      return [hours, min, sec];
    }
    return null;
  }

  /// returns 0 if egal, -1 if [time1]<[time2], +1 if [time1]>[time2]
  static int compareTimes(List<int> time1, List<int> time2) {
    if (time1[0] != time2[0]) {
      return time1[0] - time2[0];
    }
    if (time1[1] != time2[1]) {
      return time1[1] - time2[1];
    }
    if (time1[2] != time2[2]) {
      return time1[2] - time2[2];
    }
    return 0;
  }

  static List<int> smallest(List<int> time1, List<int> time2) {
    if (compareTimes(time1, time2) <= 0) {
      return time1;
    }
    return time2;
  }

  static List<int> greatest(List<int> time1, List<int> time2) {
    if (compareTimes(time1, time2) >= 0) {
      return time1;
    }
    return time2;
  }

  static int findTime(List<List<int>> times, List<int> time) {
    for (int idx = 0; idx < times.length; idx++) {
      if (compareTimes(times[idx], time) == 0) {
        return idx;
      }
    }
    return -1;
  }

  /// [precision] indicates, in minute the precision of the result.
  /// Example: if precision=10, then a result of 10H15 will be floored to 10H10
  static List<int> addTime(List<int> time1, List<int> time2, {int precision = 0}) {
    int totalsec = (time1[0] + time2[0]) * 3600 + (time1[1] + time2[1]) * 60 + time1[2] + time2[2];
    totalsec = min(max(totalsec, 0), 24 * 3600);
    int hour = totalsec ~/ 3600;
    int min_ = (totalsec % 3600) ~/ 60;
    int sec = totalsec - hour * 3600 - min_ * 60;
    if (precision > 0) {
      min_ = (min_ ~/ precision) * precision;
      sec = 0;
    }
    return [hour, min_, sec];
  }

  static List<int> subTime(List<int> time1, List<int> time2, {int precision = 1}) {
    return addTime(time1, [-time2[0], -time2[1], -time2[2]]);
  }

  static List<int> fromMinutes(int minutes) {
    int hour = minutes ~/ 60;
    int min_ = (minutes % 60);
    return [hour, min_, 0];
  }

  static int getTotalMinutes(List<int> time) {
    return time[0] * 60 + time[1];
  }

  static String timeToString(List<int> time) {
    return '${time[0].toString().padLeft(2, '0')}:${time[1].toString().padLeft(2, '0')}:${time[2].toString().padLeft(2, '0')}';
  }
}

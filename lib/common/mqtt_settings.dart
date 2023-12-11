import 'package:shared_preferences/shared_preferences.dart';

/// Defines the MQTT part of app settings
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
/// 

class MQTTSettings {
  MQTTSettings();
  MQTTSettings.fromMap(Map config)
      : sendTopic = config['SendTopic'],
        onIsAliveTopic = config['onIsAliveTopic'],
        onResponseTopic = config['onResponseTopic'],
        onSchedulerTopic = config['onSchedulerTopic'],
        onDevicesTopic = config['onDevicesTopic'],
        onEntitiesTopic = config['onEntitiesTopic'],
        onDeviceChangeTopic = config['onDeviceChangeTopic'],
        brokerAddress = config['brokerAddress'],
        port = config['port'],
        secure = config['secure'],
        user = config['user'],
        password = config['password'],
        isAliveTimeout = config['isAliveTimeout'];

  void saveToSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('brokerAddress', brokerAddress);
    prefs.setString('user', user);
    prefs.setString('password', password);
    prefs.setInt('port', port);
    prefs.setBool('secure', secure);
    // TBD
  }

  String sendTopic = '';
  String onIsAliveTopic = '';
  String onResponseTopic = '';
  String onSchedulerTopic = '';
  String onDevicesTopic = '';
  String onEntitiesTopic = '';
  String onDeviceChangeTopic = '';
  int    isAliveTimeout = 0;

  int port = 0;
  bool secure = false;
  String brokerAddress = '';
  String user = '';
  String password = '';
}

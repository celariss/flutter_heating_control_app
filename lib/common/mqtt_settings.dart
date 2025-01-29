import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Defines the MQTT part of app settings
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
/// 

class MQTTSettings {
  MQTTSettings();
  MQTTSettings.fromMap(Map config)
      : sendTopic = config.containsKey('SendTopic') ? config['SendTopic'] : '',
        onIsAliveTopic = config.containsKey('onIsAliveTopic') ? config['onIsAliveTopic'] : '',
        onResponseTopic = config.containsKey('onResponseTopic') ? config['onResponseTopic'] : '',
        onSchedulerTopic = config.containsKey('onSchedulerTopic') ? config['onSchedulerTopic'] : '',
        onDevicesTopic = config.containsKey('onDevicesTopic') ? config['onDevicesTopic'] : '',
        onEntitiesTopic = config.containsKey('onEntitiesTopic') ? config['onEntitiesTopic'] : '',
        onDeviceChangeTopic = config.containsKey('onDeviceChangeTopic') ? config['onDeviceChangeTopic'] : '',
        brokerAddress = config.containsKey('brokerAddress') ? config['brokerAddress'] : '',
        port = config.containsKey('port') ? config['port'] : 0,
        secure = config.containsKey('secure') ? config['secure'] : true,
        user = config.containsKey('user') ? config['user'] : '',
        password = config.containsKey('password') ? config['password'] : '',
        isAliveTimeout = config.containsKey('isAliveTimeout') ? config['isAliveTimeout'] : 8;

  Future<void> readFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    brokerAddress = await _storage.read(key: 'brokerAddress') ?? brokerAddress;
    user = await _storage.read(key: 'user') ?? user;
    password = await _storage.read(key: 'password') ?? password;
    port = prefs.getInt('port') ?? port;
    secure = prefs.getBool('secure') ?? secure;
  }

  void saveToSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _storage.write(key: 'brokerAddress', value:brokerAddress);
    await _storage.write(key: 'user', value:user);
    await _storage.write(key: 'password', value:password);
    await prefs.setInt('port', port);
    await prefs.setBool('secure', secure);
  }

  final FlutterSecureStorage _storage = FlutterSecureStorage();


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

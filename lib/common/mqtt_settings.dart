/// Defines the MQTT part of app settings
///
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
/// 

class MQTTSettings {
  MQTTSettings();
  MQTTSettings.fromMap(Map config)
      : sendTopic = config['SendTopic'],
        onResponseTopic = config['onResponseTopic'],
        onSchedulerTopic = config['onSchedulerTopic'],
        onDevicesTopic = config['onDevicesTopic'],
        onDeviceChangeTopic = config['onDeviceChangeTopic'],
        brokerAddress = config['brokerAddress'],
        port = config['port'],
        secure = config['secure'],
        user = config['user'],
        password = config['password'];

  String sendTopic = '';
  String onResponseTopic = '';
  String onSchedulerTopic = '';
  String onDevicesTopic = '';
  String onDeviceChangeTopic = '';

  int port = 0;
  bool secure = false;
  String brokerAddress = '';
  String user = '';
  String password = '';
}

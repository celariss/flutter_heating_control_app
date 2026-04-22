/// This file defines a client for mqtt that is specific to desktop/mobile platform
/// It uses mqtt_server_client from mqtt_client package
/// 
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttUtil {
  static MqttServerClient createClient(String broker, String clientId) {
    return MqttServerClient(broker, clientId);
  }

  static void configureClient(MqttClient client, bool ssl, bool websocket) {
    if (websocket) {
      // client.secure is only for TCP
      (client as MqttServerClient).secure = false;
    }
    else {
      (client as MqttServerClient).secure = ssl;
    }
    client.useWebSocket = websocket;
  }
}
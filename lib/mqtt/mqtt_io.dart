/// This file defines a client for mqtt that is specific to desktop/mobile platform
/// It uses mqtt_server_client from mqtt_client package
/// 
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttUtil {
  static MqttServerClient createClient(String broker, String clientId, int port, bool ssl) {
    return MqttServerClient.withPort((ssl ? 'wss://' : 'ws://') + broker, clientId, port);
  }

  static void configureClient(MqttClient client) {
    (client as MqttServerClient).useWebSocket = true;
  }
}
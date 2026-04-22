/// This file defines a client for mqtt that is specific to web platform
/// It uses mqtt_browser_client from mqtt_client package
/// 
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

class MqttUtil {
  static MqttBrowserClient createClient(String broker, String clientId) {
    return MqttBrowserClient(broker, clientId);
  }

  static void configureClient(MqttClient client, bool ssl, bool websocket) {
    //client.websocketProtocols = ['mqtt'];
  }
}
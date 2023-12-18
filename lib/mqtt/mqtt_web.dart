/// This file defines a client for mqtt that is specific to web platform
/// It uses mqtt_browser_client from mqtt_client package
/// 
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library mqtt_web;

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

class MqttUtil {
  static createClient(String broker, String clientId, int port, bool ssl) {
    return MqttBrowserClient.withPort((ssl ? 'wss://' : 'ws://') + broker, clientId, port);
  }

  static configureClient(MqttClient client) {
    //client.websocketProtocols = ['mqtt'];
  }
}
/// This file defines a base implementation for a mqtt_client
/// 
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'package:mqtt_client/mqtt_client.dart';

class MqttUtil {
  static MqttClient createClient(String broker, String clientId) {
    throw UnsupportedError('Cannot create untyped mqtt client');
  }

  static void configureClient(MqttClient client, bool ssl, bool websocket) {
    throw UnsupportedError('Cannot configure untyped mqtt client');
  }
}
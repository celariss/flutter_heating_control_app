/// This file defines a base implementation for a mqtt_client
/// 
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'package:mqtt_client/mqtt_client.dart';

class MqttUtil {
  static createClient(String broker, String clientId, int port, bool ssl) {
    throw UnsupportedError('Cannot create untyped mqtt client');
  }

  static configureClient(MqttClient client) {

  }
}
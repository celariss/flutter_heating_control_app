/// This file defines a client for mqtt that works in all contexts (web / desktop / mobile)
/// It uses mqtt_stub.dart
/// Platform specific implementation can be found in mqtt_io.dart and mqtt_web.dart
/// 
/// Authors: Jérôme Cuq
/// License: BSD 3-Clause
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter/foundation.dart';

import 'mqtt_stub.dart' if (dart.library.js) 'mqtt_web.dart' if (dart.library.io) 'mqtt_io.dart';

class MQTTClient {
  MqttClient client;
  String broker;
  int port;
  String user;
  String password;
  bool ssl;
  bool websocket;
  String clientID;

  /// Client disconnect callback, called on unsolicited disconnect.
  void Function(bool unexpected)? onDisconnected;

  /// Client connect callback, called on successful connect
  void Function()? onConnected;

  void Function(String topic, String payload)? onMessageString;

  MQTTClient(this.broker, this.port, {this.ssl = true, this.user = '', this.password = '', this.websocket = true, this.clientID = 'mqtt_client_flutter'}) :
    client = MqttUtil.createClient(broker, clientID);

  void logging({required bool enable}) {
    client.logging(on: enable);
  }

  Future<MqttClientConnectionStatus> connect({bool startClean = true}) async {
    return _connect(startClean: startClean);
  }

  Future<MqttClientConnectionStatus> connectWithCredentials(String user, String password,
      {bool startClean = true}) async {
    this.user = user;
    this.password = password;
    return _connect(startClean: startClean);
  }

  Future<MqttClientConnectionStatus> _connect({bool startClean = true}) async {
    if (websocket) {
      if (ssl) {
        client = MqttUtil.createClient('wss://$broker', clientID);
      } else {
        client = MqttUtil.createClient('ws://$broker', clientID);
      }
      client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    }
    else {
      client = MqttUtil.createClient(broker, clientID);
    }

    MqttUtil.configureClient(client, ssl, websocket);
    
    client.setProtocolV311();
    client.port = port;
    client.keepAlivePeriod = 10;
    client.connectTimeoutPeriod = 2000; // milliseconds
    client.autoReconnect = true;
    if (onConnected != null) {
      client.onConnected = onConnected;
    }
    client.onDisconnected = _onDisconnected;

    final connMess = MqttConnectMessage()
        //.withClientIdentifier('Mqtt_MyClientUniqueId')
        .authenticateAs(user, password)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;
    if (startClean) {
      client.connectionMessage?.startClean();
    }

    //client.logging(on:true);

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      debugPrint('Socket exception: $e');
    } on SocketException catch (e) {
      // Raised by the socket layer
      debugPrint('Socket exception: $e');
    } on ArgumentError catch (e) {
      // Raised when the url has an invalid format
      debugPrint('Socket exception: $e');
    } on Exception catch (e) {
      // Other Exception
      debugPrint('Socket exception: $e');
    }

    /// Check we are connected
    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      client.disconnect();
    } else {
      /// The client has a change notifier object(see the Observable class) which we then listen to get
      /// notifications of published updates to each subscribed topic.
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final pt = utf8.decode(recMess.payload.message);
        if (onMessageString != null) {
          onMessageString!(c[0].topic, pt);
        }
      });
    }

    return client.connectionStatus!;
  }

  void subscribe(String topic) {
    if (client.getSubscriptionsStatus(topic) == MqttSubscriptionStatus.doesNotExist) {
      client.subscribe(topic, MqttQos.exactlyOnce);
    }
  }

  void unsubscribe(String topic) {
    if (client.getSubscriptionsStatus(topic) != MqttSubscriptionStatus.doesNotExist) {
      client.unsubscribe(topic);
    }
  }

  bool publish(String topic, String strPayload, {retain = false, qos = MqttQos.exactlyOnce}) {
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(strPayload);
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.publishMessage(topic, qos, builder.payload!, retain: retain);
      return true;
    }
    return false;
  }

  void disconnect() {
    client.disconnect();
  }

  bool isConnected() {
    if (client.connectionStatus != null) {
      return (client.connectionStatus!.state == MqttConnectionState.connected);
    }
    return false;
  }

  /// The unsolicited disconnect callback
  void _onDisconnected() {
    if (onDisconnected != null) {
      if (client.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
        // callback is solicited, this is correct
        onDisconnected!(false);
      } else {
        // callback is unsolicited or none, this is incorrect
        onDisconnected!(true);
      }
    }
  }
}

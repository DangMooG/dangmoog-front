// ignore_for_file: avoid_print, library_prefixes

import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

typedef ChatReceivedCallback = void Function(Map<String, dynamic>);

class SocketProvider {
  late IO.Socket socket;
  late ChatReceivedCallback onChatReceived;
  int retryCount = 0;
  static const int maxRetryCount = 5;
  late String socketUrl;

  SocketProvider();
  // 채팅을 받았을 때 어떻게 처리할 건지 설정
  void setChatReceivedCallback(ChatReceivedCallback callback) {
    onChatReceived = callback;
  }

  void onConnect() async {
    const socketBaseUrl = "chat.dangmoog.site:4048";
    socketUrl = 'http://$socketBaseUrl';

    const storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'accessToken');

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': maxRetryCount,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'path': '/ws/socket.io',
      'auth': {
        'token': accessToken,
      },
    });

    socket.onConnect((_) {
      print("Socket Connected");
    });

    socket.onDisconnect((_) {
      socket.emit('disconnect', [accessToken]);
      print("Socket Disconnected");
    });

    socket.on('message', (data) async {
      onChatReceived.call(data);
    });

    socket.onConnectError((data) {
      print("Socket connection error: $data");
    });

    try {
      socket.connect();
    } catch (e) {
      print(e);
    }
  }

  void beginChat(String roomId) {
    socket.emit('begin_chat', [roomId]);
  }

  void exitChat(String roomId) {
    socket.emit('exit_chat', [roomId]);
  }

  Future<void> onSendMessage(
    String? message,
    List<dynamic>? photoUrls,
    String roomId,
    bool isImage,
  ) async {
    var messageDict = {
      "room": roomId,
      "type": isImage ? 'img' : 'txt',
      'content': message ?? photoUrls,
    };

    if (checkSocketAndReconnect() == true) {
      socket.emit('send_chat', [messageDict]);
    } else {}
  }

  bool checkSocketAndReconnect() {
    if (!socket.connected) {
      print("Socket is not connected. Attempting to reconnect...");
      try {
        socket.connect();
        socket.onConnect((_) async {
          print("Socket is reconnected.");
          return true;
        });
        socket.onConnectError((data) {
          return false;
        });
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  void dispose() {
    socket.dispose();
  }
}

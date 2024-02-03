import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef ChatReceivedCallback = void Function(String message);

class SocketProvider {
  late IO.Socket socket;

  // 채팅을 받았을 때 실행할 함수
  late ChatReceivedCallback onChatReceived;

  int retryCount = 0;
  static const int maxRetryCount = 3;

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
      'reconnectionDelay': 2000,
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
    });

    socket.on('chat', (data) {
      onChatReceived.call(data);
    });

    socket.onConnectError((data) {
      print("연결 에러: $data");
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

  Future<void> onSendMessage(String message, String roomId) async {
    var messageDict = {
      'content': message,
      "room": roomId,
    };
    socket.emit('send_chat', [messageDict]);
  }

  void dispose() {
    socket.dispose();
  }
}

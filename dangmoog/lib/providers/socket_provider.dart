// ignore_for_file: avoid_print, library_prefixes

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef ChatReceivedCallback = void Function(Map<String, dynamic>);

class SocketProvider {
  late IO.Socket socket;
  late ChatReceivedCallback onChatReceived;
  int retryCount = 0;
  static const int maxRetryCount = 5;
  late String socketUrl;

  Timer? pingTimer; // Timer 객체를 관리하기 위한 변수

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

    // socket = IO.io(socketUrl, <String, dynamic>{
    //   'transports': ['websocket'],
    //   'autoConnect': false,
    //   'reconnection': true,
    //   'reconnectionAttempts': maxRetryCount,
    //   'reconnectionDelay': 1000,
    //   'reconnectionDelayMax': 5000,
    //   'path': '/ws/socket.io',
    //   'auth': {
    //     'token': accessToken,
    //   },
    // });

    // OptionBuilder를 사용하여 옵션을 구성합니다.
    IO.OptionBuilder optionBuilder = IO.OptionBuilder()
        .setTransports(['websocket']) // 웹소켓 전송을 사용
        .disableAutoConnect() // 자동 연결을 비활성화
        .enableReconnection() // 재연결을 활성화
        .setReconnectionAttempts(maxRetryCount) // 최대 재연결 시도 횟수를 설정
        .setReconnectionDelay(1000) // 재연결 지연 시간(최소)을 설정
        .setReconnectionDelayMax(5000) // 재연결 지연 시간(최대)을 설정
        .setPath('/ws/socket.io') // 서버의 소켓 경로를 설정
        .setAuth({'token': accessToken}); // 인증 토큰을 설정

    socket = IO.io(socketUrl, optionBuilder.build());

    socket.onConnect((_) {
      print("Socket Connected");

      // // Timer 설정: 60초마다 ping 메시지를 서버에 보냅니다.
      // pingTimer =
      //     Timer.periodic(const Duration(seconds: 10), (Timer t) => sendPing());

      // Timer 설정: 60초마다 ping 메시지를 서버에 보냅니다.
      pingTimer =
          Timer.periodic(const Duration(seconds: 60), (Timer t) => sendPing());

      // pong 메시지를 받는 리스너 설정
      socket.on('hello', (_) async {
        print("Pong received");
      });
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

  // 소켓 연결 유지를 위한 ping-pong
  void sendPing() {
    try {
      socket.emit('hey');
      print("Ping sent");
    } catch (e) {
      print(e);
    }
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

    if (await checkSocketAndReconnect() == true) {
      socket.emit('send_chat', [messageDict]);
    } else {
      print("Failed to reconnect to the socket.");
    }
  }

  // 소켓 연결 상태를 확인하고 재연결을 시도합니다. 연결 성공 여부를 Future<bool>로 반환합니다.
  Future<bool> checkSocketAndReconnect() async {
    Completer<bool> completer =
        Completer<bool>(); // 연결 성공 여부를 처리하기 위한 Completer

    if (!socket.connected) {
      print("Socket is not connected. Attempting to reconnect...");

      try {
        // 연결 시도
        socket.connect();

        // 연결 성공 시
        socket.onConnect((_) async {
          print("Socket is reconnected.");
          if (!completer.isCompleted) {
            completer.complete(true); // 연결 성공을 나타내는 true를 반환합니다.
          }
        });

        // 연결 시도 중 에러 발생 시
        socket.onConnectError((data) {
          print("Socket reconnection error: $data");
          if (!completer.isCompleted) {
            completer.complete(false); // 연결 실패를 나타내는 false를 반환합니다.
          }
        });
      } catch (e) {
        print("Socket reconnection failed: $e");
        if (!completer.isCompleted) {
          completer.complete(false); // 예외 발생 시 연결 실패를 나타내는 false를 반환합니다.
        }
      }
    } else {
      // 이미 연결되어 있을 경우, 바로 true를 반환합니다.
      return Future.value(true);
    }

    return completer.future; // 연결 성공 여부에 대한 Future<bool>를 반환합니다.
  }

  void dispose() {
    socket.dispose();
    pingTimer?.cancel();
  }
}

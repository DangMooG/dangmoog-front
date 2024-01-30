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
    const storage = FlutterSecureStorage();

    const socketBaseUrl = "chat.dangmoog.site:2024";
    String? accessToken = await storage.read(key: 'accessToken');
    socketUrl = 'http://$socketBaseUrl/chat';

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': maxRetryCount,
      'reconnectionDelay': 2000,
      'reconnectionDelayMax': 5000,
    });

    socket.onConnect((_) {
      socket.emit('connect', [socket.id, accessToken]);
    });

    socket.onDisconnect((_) {
      socket.emit('disconnect', [socket.id, accessToken]);
    });

    socket.on('chat', (data) {
      onChatReceived.call(data);
    });

    socket.onConnectError((data) {
      print("연결 에러: $data");
    });

    socket.connect();
  }

  void beginChat(String roomId) {
    socket.emit('begin_chat', [socket.id, roomId]);
  }

  void exitChat(String roomId) {
    socket.emit('exit_chat', [socket.id, roomId]);
  }

  void onSendMessage(String message, String roomId) {
    var messageDict = {'message': message};
    socket.emit('send_chat', [socket.id, roomId, messageDict]);
  }

  void dispose() {
    socket.dispose();
  }
}

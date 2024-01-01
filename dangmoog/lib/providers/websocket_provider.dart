import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef MessageReceivedCallback = void Function(String message);

class SocketClass {
  late WebSocketChannel channel;
  MessageReceivedCallback? onMessageReceived;

  SocketClass();

  void onConnect() async {
    const storage = FlutterSecureStorage();
    const socketBaseUrl =
        "port-0-dangmoog-chat-p8xrq2mlfc80j33.sel3.cloudtype.app";
    final accessToken = await storage.read(key: 'accessToken');
    final wsUrl = 'ws://$socketBaseUrl/ws?token=$accessToken';

    channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // 연결이 성공했을 때 할 작업
    channel.stream.listen(
      (message) {
        // 서버로부터 메시지 수신
        print('Received: $message');
        onMessageReceived?.call(message);
      },
      onError: (error) {
        // 오류 발생 시 처리
        print(error);
      },
      onDone: () {
        // WebSocket이 닫힐 때 실행
        print('WebSocket connection closed.');
      },
    );
  }

  void onSendMessage(String message, String roomId) {
    channel.sink.add("$roomId$message");
  }

  void dispose() {
    channel.sink.close();
  }
}

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef ChatReceivedCallback = void Function(String message);

class SocketProvider {
  late WebSocketChannel channel;

  // 채팅을 받았을 때 실행할 함수
  late ChatReceivedCallback onChatReceived;

  int retryCount = 0;
  static const int maxRetryCount = 3;

  late String wsUrl;

  SocketProvider();

  // 채팅을 받았을 때 어떻게 처리할 건지 설정
  void setChatReceivedCallback(ChatReceivedCallback callback) {
    onChatReceived = callback;
  }

  void onConnect() async {
    const storage = FlutterSecureStorage();
    const socketBaseUrl =
        "port-0-dangmoog-chat-p8xrq2mlfc80j33.sel3.cloudtype.app";
    String? accessToken = await storage.read(key: 'accessToken');
    wsUrl = 'ws://$socketBaseUrl/ws?token=$accessToken';

    channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // 연결이 성공했을 때 할 작업
    channel.stream.listen(
      (message) {
        // 서버로부터 메시지 수신
        print(message);
        onChatReceived.call(message);
      },
      onError: (error) {
        print("소켓 연결 에러 발생. 재연결 시도");
        onConnect();
      },
      onDone: () {
        print('소켓 연결 끊김. 재연결 시도.');
        onConnect();
      },
    );
  }

  // 채팅 전송
  // 상세 채팅방 페이지에서 사용됨
  void onSendMessage(String message, String roomId) {
    channel.sink.add("$roomId$message");
  }

  // 소켓 재연결
  void _reconnect() async {
    if (retryCount < maxRetryCount) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        print("소켓 재연결 성공");
        retryCount = 0;
      } catch (e) {
        retryCount++;
        print('재연결 시도 실패: 시도 $retryCount');
      }
    } else {
      print('최대 재연결 시도 횟수 초과');
      // 여기서 사용자에게 알림 제공 또는 다른 조치 취하기
    }
  }

  void dispose() {
    channel.sink.close();
  }
}

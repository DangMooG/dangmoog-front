import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dangmoog/services/custom_dio.dart';

class EmailSend {
  final Dio api = dioAuthAPI();
}

final dangmoogAPI = {
  // 이메일 인증
  "emailSend": (email) async {
    final api = dioAuthAPI();

    try {
      Response response = await api.post('/account/mail_send/', data: {
        "email": email,
      });
      return response;
    } catch (e) {
      print(e);
    }
  },
  // 이메일 인증번호
  "emailVerification": (verification_number) async {
    final api = dioAuthAPI();
    const storage = FlutterSecureStorage();

    try {
      Response response = await api.post('인증번호 전송 API 주소', data: {
        "number": verification_number,
      });
      if (response.statusCode == 200) {
        String refreshToken = response.data['refresh_token'];
        String accessToken = response.data['access_token'];
        String userId = response.data['user_id'];

        await storage.write(
          key: 'access_token',
          value: accessToken,
        );
        await storage.write(
          key: 'refresh_token',
          value: refreshToken,
        );
        await storage.write(
          key: 'user_id',
          value: userId,
        );
      }
    } catch (e) {
      print(e);
    }
  },
  "userNickname": (nickName) async {
    final api = dioAPI();

    try {
      Response response = await api.post('닉네임 주소', data: {
        "nick_name": nickName,
      });
      if (response.statusCode == 200) {}
    } catch (e) {
      print(e);
    }
  }
};

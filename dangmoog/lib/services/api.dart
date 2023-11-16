import 'dart:io';

import 'package:dio/dio.dart';

import 'package:dangmoog/services/custom_dio.dart';

class ApiService {
  // 토큰이 필요한 요청은 authClient를
  // 토큰이 필요하지 않은 요청은 publicCient를 사용한다
  final Dio _publicClient = DioClient().publicClient;
  final Dio _authClient = DioClient().authClient;

  /////////////////////////////
  /// 로그인, 회원가입, 계정 관련 ///
  /////////////////////////////

  // 자동 로그인
  Future<Response> autoLogin() async {
    return await _authClient.post("account/me");
  }

  // 이메일 전송
  Future<Response> emailSend(inputEmail) async {
    return await _publicClient
        .post("account/mail_send", data: {'email': inputEmail});
  }

  // 인증번호 인증
  Future<Response> verifyCode(
      String inputEmail, String verificationCode) async {
    _publicClient.options.headers['Content-Type'] =
        "application/x-www-form-urlencoded";

    return await _publicClient.post("account/verification", data: {
      "username": inputEmail.split("@").first.toString(),
      "password": verificationCode.toString(),
    });
  }

  // 별명 중복확인
  Future<Response> checkDuplicateNickname(String nickname) async {
    return await _publicClient.post("account/check_name_duplication", data: {
      "username": nickname,
    });
  }

  // 별명 설정
  Future<Response> setUserNickname(String nickname) async {
    return await _authClient.patch("account/set_username", data: {
      "username": nickname,
    });
  }

  // 프로필 사진 설정
  Future<Response> setUserProfile(String imagePath) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(imagePath,
          filename: imagePath.split('/').last),
    });

    //_authClient.options.headers.addAll(
    // {'accept': "application/json", 'Content-Type': "multipart/form-data"});
    _authClient.options.headers['accept'] = "application/json";
    _authClient.options.headers['Content-Type'] = "multipart/form-data";
    return await _authClient.patch("account/set_user_profile_photo",
        data: formData);
  }

  // Post list 조회
  Future<Response> fetchProductData() async {
    return await _authClient.get('products.json');
  }

  // 탈퇴하기
  Future<Response> deleteAccount() async {
    return await _authClient.delete("account/");
  }
}

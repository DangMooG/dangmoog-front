import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

var options = BaseOptions(
  baseUrl:
      'https://port-0-dangmoog-api-server-p8xrq2mlfc80j33.sel3.cloudtype.app/meta/',
);

Dio dioAuthAPI() {
  return Dio(BaseOptions(
    baseUrl:
        'https://port-0-dangmoog-api-server-p8xrq2mlfc80j33.sel3.cloudtype.app/meta/',
  ));
}

Dio dioAPI() {
  const storage = FlutterSecureStorage();

  final token = storage.read(key: 'login');

  return Dio(BaseOptions(
      baseUrl:
          'https://port-0-dangmoog-api-server-p8xrq2mlfc80j33.sel3.cloudtype.app/meta/',
      headers: {
        "access_token": storage.read(key: 'access_token'),
        "refresh_token": storage.read(key: 'refresh_token'),
      }));
}

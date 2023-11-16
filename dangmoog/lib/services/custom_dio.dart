import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const BASE_URL =
    'https://port-0-dangmoog-api-server-p8xrq2mlfc80j33.sel3.cloudtype.app/meta/';

class DioClient {
  final Dio _publicClient;
  final Dio _authClient;

  static const storage = FlutterSecureStorage();

  DioClient()
      : _publicClient = Dio(
          BaseOptions(
            baseUrl: BASE_URL,
          ),
        ),
        _authClient = Dio(
          BaseOptions(
            baseUrl: BASE_URL,
          ),
        )
  {
    _authClient.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? accessToken = await storage.read(key: 'accessToken');
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Dio get publicClient => _publicClient;
  Dio get authClient => _authClient;
}

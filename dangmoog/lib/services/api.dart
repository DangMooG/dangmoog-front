import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dangmoog/services/custom_dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  // Provider를 통해서 사용자 이름 알 수 있으므로 폐기
  // Future<String?> getUsername() async {
  //   try {
  //     final response = await autoLogin();
  //     if (response.statusCode == 200) {
  //       // Assuming the response data is a Map that contains the username
  //       final username = response.data['username'];
  //       if (username is String) {
  //         return username;
  //       } else {
  //         throw Exception('Username is not a string');
  //       }
  //     } else {
  //       // Handle non-200 status code
  //       throw Exception('Failed to auto login');
  //     }
  //   } catch (e) {
  //     // Handle exception
  //     rethrow;
  //   }
  // }

  /////////////////////////////
  /// 물품 관련 ///
  /////////////////////////////

  Future<Response> createPost({
    required String title,
    required int price,
    required String description,
    required int categoryId,
    required int useLocker,
    List<File>?
    imageFiles, // Make sure this parameter is available in your method signature.
  }) async {
    // Prepare the query parameters
    final queryParams = {
      "title": title,
      "price": price.toString(),
      "description": description,
      "category_id": (categoryId + 1).toString(),
      "use_locker": useLocker.toString(),
    };

    // Construct the query string
    final queryString = Uri(queryParameters: queryParams).query;

    // Construct the URL with query parameters
    final String url = '/post/create_with_photo?$queryString';

    // Initialize a list for MultipartFiles
    List<MultipartFile> multipartImageList = [];

    // If imageFiles are provided, prepare them for FormData
    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (var file in imageFiles) {
        String fileName =
            file.path; // Use the 'path' package to get a file name.
        multipartImageList
            .add(await MultipartFile.fromFile(file.path, filename: fileName));
      }
    }

    // Create FormData
    FormData formData = FormData.fromMap({
      "files": multipartImageList, // API expects 'files', so use that as key
    });

    // Use the FormData object with your post request
    return await _authClient.post(
      url,
      data: formData,
    );
  }

  Future<Response> loadList() async {
    return await _publicClient.get("post/list");
  }

  Future<Response> loadProduct(int id) async {
    return await _publicClient.get("post/$id");
  }

  Future<Response> loadLikes() async {
    return await _authClient.post("post/get_like_list");
  }

  Future<Response> searchPosts(Map<String, dynamic> filters) async {
    try {
      final response = await _publicClient.post(
        'post/search',
        data: filters,
      );
      return response;
    } catch (e) {
      // Handle exception, or rethrow to be handled by the calling function
      rethrow;
    }
  }

  /////////////////////////////
  /// 채팅 관련 ///
  /////////////////////////////

  Future<int> chatCount(int id) async {
    try {
      Response response = await _publicClient.get("chat/$id");
      if (response.statusCode == 200) {
        return response.data; // Return the list of chats
      } else if (response.statusCode == 404 || response.statusCode == 422) {
        return 0; // Return an empty list
      } else {
        // Handle other errors
        throw Exception('Failed to load chats');
      }
    } catch (e) {
      // If there's an error, return an empty list
      return 0;
    }
  }

  /////////////////////////////
  /// 사진 관련 ///
  /////////////////////////////
  Future<Response> loadPhoto(int id) async {
    try {
      Response response = await _publicClient.get("photo/$id");
      if (response.statusCode == 200) {
        return response; // Return the list of chats
      } else if (response.statusCode == 404 || response.statusCode == 422) {
        return response; // Return an empty list
      } else {
        // Handle other errors
        throw Exception('Failed to load photo');
      }
    } catch (e) {
      // If there's an error, return an empty list
      return Future.error(e);
    }
  }

  Future<Response> searchPhoto(int postId) async {
    Map<String, dynamic> requestBody = {
      "post_id": postId,
    };
    return await _publicClient.post(
      "photo/search",
      data: requestBody,
    );
  }

  ////////////////
  /// 좋아요 관련 ///
  ////////////////
  Future<Response> increaseLike(int id) async {
    // Make the HTTP request first
    Response response =
    await _authClient.post("post/like_up", queryParameters: {'id': id});
    return response;
  }

  Future<Response> decreaseLike(int id) async {
    // Make the HTTP request first
    Response response =
    await _authClient.post("post/like_back", queryParameters: {'id': id});
    return response;
  }

  Future<Response> getLikeList() async{
    Response response=
        await _authClient.post("post/get_like_list");
    return response;
  }

  ////////////////
  /// 사물함 관련 ///
  ////////////////
  Future<Response> loadLocker() async {
    // Make the HTTP request first
    Response response = await _publicClient.get("locker/list");
    return response;
  }

  Future<Response> searchLocker(Map<String, dynamic> filters) async {
    try {
      final response = await _publicClient.post(
        'locker/search',
        data: filters,
      );
      return response;
    } catch (e) {
      // Handle exception, or rethrow to be handled by the calling function
      rethrow;
    }
  }

  Future<Response> patchLocker(
      int lockerId, Map<String, dynamic> updates) async {
    Response response = await _authClient.patch(
      'locker/$lockerId',
      data: updates,
    );
    return response;
  }
}
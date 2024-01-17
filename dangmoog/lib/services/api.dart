import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dangmoog/services/custom_dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // 토큰이 필요한 요청은 authClient를
  // 토큰이 필요하지 않은 요청은 publicCient를 사용한다
  final Dio _publicClient = DioClient().publicClient;
  final Dio _authClient = DioClient().authClient;
  final Dio _aiClient = DioClient().aiClient;

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
      "fcm": "jasidofjgaoiwjijwaofju20lakdjfkl"
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

  // 내가 올린 게시글 목록 조회
  Future<Response> getMyPostListId() async {
    return await _authClient.post('post/my_post');
  }

  // 탈퇴하기
  Future<Response> deleteAccount() async {
    return await _authClient.delete("account/");
  }

  /////////////////////////////
  /// 물품 관련 ///
  /////////////////////////////

  Future<Response> getPriceRecommended(String title, File imageFile) async {
    String fileName = imageFile.path;

    MultipartFile multipartImage =
        await MultipartFile.fromFile(imageFile.path, filename: fileName);

    FormData formData = FormData.fromMap({
      "photo": multipartImage,
    });

    return await _aiClient.post("predict/get_price?title=$title",
        data: formData);
  }

  // 게시글 업로드
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

    // Check if imageFiles are provided and not empty
    if (imageFiles != null && imageFiles.isNotEmpty) {
      // Initialize a list for MultipartFiles
      List<MultipartFile> multipartImageList = [];

      // Prepare the image files for FormData
      for (var file in imageFiles) {
        String fileName =
            file.path; // Use the 'path' package to get a file name.
        multipartImageList
            .add(await MultipartFile.fromFile(file.path, filename: fileName));
      }

      // Create FormData with files
      FormData formData = FormData.fromMap({
        "files": multipartImageList, // API expects 'files', so use that as key
      });

      // Send the post request with formData when there are images
      return await _authClient.post(
        url,
        data: formData,
      );
    } else {
      // Send the post request without formData when there are no images
      return await _authClient.post(
        url,
      );
    }
  }

  // 게시글 수정
  Future<Response> patchPost({
    required int postId,
    String? title,
    int? price,
    String? description,
    int? categoryId,

    // List<File>? imageFiles,
  }) async {
    // print(postId);
    // print(price);
    // print(description);
    // print(categoryId);

    Map<String, dynamic> updatedData = {
      if (title != null) "title": title,
      if (price != null) "price": price,
      if (description != null) "description": description,
      if (categoryId != null) "category_id": categoryId,
    };

    // FormData formData = FormData.fromMap(updatedData);

    return await _authClient.patch(
      '/post/$postId',
      data: updatedData,
    );
  }

  Future<Response> deletePost(int id) async {
    return await _authClient.delete("post/$id");
  }

  Future<Response> loadList() async {
    return await _publicClient.get("post/list");
  }

  Future<Response> loadProduct(int id) async {
    return await _publicClient.get("post/$id");
  }

  Future<Response> loadLockerPost() async {
    String apiUrl = "post/not_yet_auth";
    Response response = await _authClient.post(apiUrl);
    return response;
  }

  Future<Response> loadProductListWithPaging(int checkpoint) async {
    if (checkpoint == 0) {
      return await _publicClient.get("post/app-paging", queryParameters: {
        "size": 20,
      });
    } else {
      return await _publicClient.get("post/app-paging", queryParameters: {
        "size": 20,
        "checkpoint": checkpoint,
      });
    }
  }

  Future<Response> loadLikes() async {
    return await _authClient.post("post/get_like_list");
  }

  Future<Response> loadPurchase(Map<String, dynamic> filters) async {
    try {
      final response = await _authClient.post(
        'post/my_items',
        data: filters,
      );
      return response;
    } catch (e) {
      // Handle exception, or rethrow to be handled by the calling function
      rethrow;
    }
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

  Future<Response> valLockerPost(
      int postId, int lockerId, String password, File imageFile) async {
    // Define the URL endpoint
    print(imageFile.path.split('/').last);
    print(lockerId);
    print(postId);
    print(password);

    // Create a FormData object with the single image
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path,
          filename: imageFile.path.split('/').last),
    });

    // Prepare the query parameters
    final queryParams = {
      'post_id': postId.toString(),
      'locker_id': lockerId.toString(),
      'password': password,
    };

    // Construct the query string
    final queryString = Uri(queryParameters: queryParams).query;

    // Construct the URL with query parameters
    final String url = '/locker/locker_auth?$queryString';

    try {
      // Perform the POST request
      Response response = await _authClient.post(
        url,
        data: formData,
      );

      // Return the response
      return response;
    } catch (e) {
      // Handle any errors
      print("Failed to upload data: $e");

      // Rethrow the error or provide a default response
      rethrow; // Rethrow to be handled by the caller.
      // OR
      // return Response(statusCode: 500, statusMessage: 'Internal Server Error'); // Provide a default response
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

  Future<Response> getChatRoomId(int postId) async {
    Map<String, dynamic> requestBody = {
      "post_id": postId,
    };
    return await _authClient.post("chat/create_post_chat_room",
        data: requestBody);
  }

  // 한 채팅방에 대한 모든 채팅 정보 얻기
  Future<Response> getChatAllMessages(String roomId) async {
    return await _publicClient.get("chat/all/$roomId");
  }

  // 한 채팅방에 해당하는 게시글 id 얻기
  Future<Response> getPostIdByRoomId(String roomId) async {
    return await _publicClient.get("chat/$roomId");
  }

  // 내가 속한 모든 채팅방의 id 얻기
  Future<Response> getMyRoomIds() async {
    return await _authClient.post("chat/my_rooms");
  }

  // 여러 채팅방에 대해 내가 구매자 or 판매자인지, postId
  Future<Response> getAllMyChatRoomInfo(List<String> roomIds) async {
    Map<String, dynamic> requestBody = {"rooms": roomIds};
    return await _authClient.post("chat/room_info", data: requestBody);
  }

  // 여러 채팅방의 상대방 닉네임 가져오기
  Future<Response> getChatUserNames(List<String> roomIds) async {
    Map<String, dynamic> requestBody = {"rooms": roomIds};
    return await _authClient.post("chat/my_opponents", data: requestBody);
  }

  Future<Response> getAllMyChatRoomStatus(List<String> roomIds) async {
    Map<String, dynamic> requestBody = {"rooms": roomIds};
    return await _authClient.post("chat/my_room_status", data: requestBody);
  }

  Future<Response> changeDealStatus(int status, int postId) async {
    Map<String, int> requestBody = {"status": status};
    return await _authClient.patch("post/$postId", data: requestBody);
  }

  ///////////////
  /// 사진 관련 ///
  ///////////////
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

  Future<Response> getOnePhoto(int photoId) async {
    return await _publicClient.get('photo/$photoId');
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

  Future<Response> getLikePostList() async {
    Response response = await _authClient.post("post/get_like_list");
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

  Future<Response> getLockerInfo(int postId) async {
    return await _authClient.get('locker/locker_auth/$postId');
  }
}

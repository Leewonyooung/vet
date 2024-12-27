import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/token_access.dart';

class Myapi extends TokenAccess {
makeAuthenticatedRequest(String url, {String method = 'GET', Map<String, dynamic>? body, int retryCount = 0}) async {
  if (Get.find<LoginHandler>().box.read('userEmail') == null || 
      Get.find<LoginHandler>().box.read('userEmail').toString().isEmpty) {
    return null; // 로그인이 안된 상태에서는 바로 반환
  }


  // String? accessToken = await getAccessToken();

  // JWT 유효성 검증
  if (!isValidToken(accessToken)) {
    if (Get.find<LoginHandler>().box.read('userEmail') == null || 
        Get.find<LoginHandler>().box.read('userEmail').toString().isEmpty) {
      return null;
    }
    // final tokenRefreshed = await refreshAccessToken();
    // if (!tokenRefreshed) {
    //   throw Exception("Failed to refresh access token");
    // }
    // accessToken = await getAccessToken();
  }

  try {
    var request = http.Request(method, Uri.parse(url))
      ..headers.addAll({
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });
    request.body = body != null ? jsonEncode(body) : '';

    final streamedResponse = await request.send();
    
    final res = await http.Response.fromStream(streamedResponse);

    // if (res.statusCode == 401 && retryCount < maxRetry) {
    //   final tokenRefreshed = await refreshAccessToken();
    //   if (tokenRefreshed) {
    //     accessToken = await getAccessToken();
    //     return await makeAuthenticatedRequest(url, method: method, body: body, retryCount: retryCount + 1);
    //   } else {
    //     throw Exception("Failed to refresh access token after 401");
    //   }
    // }

    if (res.statusCode >= 400) {
      throw Exception("Request failed with status: ${res.statusCode}");
    }

    return res;
  } catch (e) {
    return null; // 예외 발생 시 안전하게 null 반환
  }
}



  bool isValidToken(String? token) {
    if (token == null || token.isEmpty) return false;
    final segments = token.split('.');
    return segments.length == 3;
  }
}

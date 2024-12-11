import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vet_app/vm/token_access.dart';

class Myapi extends TokenAccess {
  Future<http.Response> makeAuthenticatedRequest(String url, {String method = 'GET', Map<String, dynamic>? body}) async {
    String? accessToken = await getAccessToken();
    print(await secureStorage.read(key:'accessToken'));
    print(await secureStorage.read(key:'refreshToken'));
    // JWT 유효성 검증
    if (!isValidToken(accessToken)) {
      print("Invalid or missing AccessToken. Attempting to refresh...");
      final tokenRefreshed = await refreshAccessToken();
      if (!tokenRefreshed) {
        // throw Exception("Failed to refresh access token");
      }
      accessToken = await getAccessToken();
    }

    try {
      // 요청 생성
      var request = http.Request(method, Uri.parse(url))
        ..headers.addAll({
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        });
      request.body = body != null ? jsonEncode(body) : '';
      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      // AccessToken 만료 시 RefreshToken 사용
      if (res.statusCode == 401) {
        print("AccessToken expired. Refreshing token...");
        final tokenRefreshed = await refreshAccessToken();
        if (tokenRefreshed) {
          // 토큰 갱신 후 다시 요청
          accessToken = await getAccessToken();
          return await makeAuthenticatedRequest(url, method: method, body: body);
        } else {
          throw Exception("Failed to refresh access token");
        }
      }

      return res;
    } catch (e) {
      print("Request failed: $e");
      rethrow;
    }
  }

  bool isValidToken(String? token) {
    if (token == null || token.isEmpty) return false;
    final segments = token.split('.');
    return segments.length == 3;
  }
}

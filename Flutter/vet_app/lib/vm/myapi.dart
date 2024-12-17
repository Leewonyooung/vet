import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vet_app/vm/token_access.dart';

class Myapi extends TokenAccess {
Future<http.Response> makeAuthenticatedRequest(String url, {String method = 'GET', Map<String, dynamic>? body, int retryCount = 0}) async {
  const int maxRetry = 1; // 재시도 최대 1회

  String? accessToken = await getAccessToken();

  // JWT 유효성 검증
  if (!isValidToken(accessToken)) {
    final tokenRefreshed = await refreshAccessToken();
    if (!tokenRefreshed) {
      throw Exception("Failed to refresh access token");
    }
    accessToken = await getAccessToken();
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

    if (res.statusCode == 401 && retryCount < maxRetry) {
      final tokenRefreshed = await refreshAccessToken();
      if (tokenRefreshed) {
        accessToken = await getAccessToken();
        return await makeAuthenticatedRequest(url, method: method, body: body, retryCount: retryCount + 1);
      } else {
        throw Exception("Failed to refresh access token");
      }
    }

    return res;
  } catch (e) {
    rethrow;
  }
}


  bool isValidToken(String? token) {
    if (token == null || token.isEmpty) return false;
    final segments = token.split('.');
    return segments.length == 3;
  }
}

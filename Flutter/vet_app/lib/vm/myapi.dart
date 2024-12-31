import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vet_app/vm/token_access.dart';

class Myapi extends TokenAccess {
makeAuthenticatedRequest(String url, {String method = 'GET', Map<String, dynamic>? body, int retryCount = 0}) async {
  try {
    var request = http.Request(method, Uri.parse(url));
    request.body = body != null ? jsonEncode(body) : '';

    final streamedResponse = await request.send();
    
    final res = await http.Response.fromStream(streamedResponse);

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

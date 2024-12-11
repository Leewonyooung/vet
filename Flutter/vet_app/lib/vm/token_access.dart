import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vet_app/vm/location_handler.dart';


class TokenAccess extends LocationHandler{
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final currentToken = ''.obs;
  String? accessToken = '';
  String refreshToken = '';
  @override
  void onInit() async {
    super.onInit();
    secureStorage.write(key: 'accessToken', value: '');
    secureStorage.write(key: 'refreshToken', value: '');
  }


  printRefreshToken() async{
    currentToken.value = getRefreshToken();
    update();
  }

  Future<String?> fetchAccessToken() async {
    return secureStorage.read(key: 'accessToken');
  }

  getAccessToken() async {
    return await secureStorage.read(key: 'accessToken');
  }

  getRefreshToken() async {
    return await secureStorage.read(key: 'refreshToken');
  }


  saveAccessToken(String token) async {
    await secureStorage.write(key: 'accessToken', value: token);
  }

  saveRefreshToken(String token) async {
    await secureStorage.write(key: 'refreshToken', value: token);
  }

  deleteTokens() async {
    await secureStorage.delete(key: 'accessToken');
    await secureStorage.delete(key: 'refreshToken');
  }

  Future<bool> refreshAccessToken() async {
  try {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      print("Missing RefreshToken");
      return false;
    }

    final response = await http.post(
      Uri.parse("$server/auth/token/refresh"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveAccessToken(data['access_token']);
      await saveRefreshToken(data['refresh_token']); // 필요시
      print("AccessToken refreshed successfully.");
      return true;
    } else {
      print("Failed to refresh AccessToken: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error refreshing token: $e");
    return false;
  }
}

}
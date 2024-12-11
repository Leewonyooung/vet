import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vet_app/model/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:vet_app/view/navigation.dart';
import 'package:vet_app/vm/chat_handler.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/user_handler.dart';

class LoginHandler extends UserHandler {
  @override
  // final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  var userdata = <UserData>[].obs;
  var savedData = <UserData>[].obs;
  var isObscured = true.obs;
  List data = [];
  String userEmail = '';
  String userName = '';
  
  // 로그인 상태 확인
  isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null &&
        getStoredEmail().isNotEmpty;
  }

  // GetStorage에서 저장된 이메일을 가져옴
  getStoredEmail() {
    return box.read('userEmail') ?? '';
  }

  // 사용자 정보를 데이터베이스에서 쿼리
  queryUser(String userEmail) async {
    var url = Uri.parse('$server/user/select?id=$userEmail');
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);

    List<UserData> savedData = [];
    String id = result[0]['id'];
    String password = result[0]['password'];
    String image = result[0]['image'];
    String name = result[0]['name'];

    savedData
        .add(UserData(id: id, password: password, image: image, name: name));
  }


// Google Sign in pop up (안창빈)
Future<UserCredential?> signInWithGoogle() async {
  try {
    // Google Sign-In
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) {
      return null; // 사용자가 로그인 취소 시 처리
    }

    final GoogleSignInAuthentication googleAuth = await gUser.authentication;
    userEmail = gUser.email;
    userName = gUser.displayName!;
    box.write('userEmail', userEmail);
    box.write('userName', userName);
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Firebase 로그인
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Firebase ID 토큰 가져오기
    final String? idToken = await userCredential.user!.getIdToken();
    if (idToken == null) {
      print("Firebase ID Token is null.");
      return null;
    }

    // 서버로 Firebase ID 토큰 전송 및 사용자 인증
    final jwtTokens = await _authenticateWithServer(idToken);

    if (jwtTokens != null) {
      try {
        // JWT 및 Refresh Token 저장
        await secureStorage.write(key: 'accessToken', value: jwtTokens['accessToken']);
        await secureStorage.write(key: 'refreshToken', value: jwtTokens['refreshToken']);
        print("Tokens saved successfully.");
      } catch (e) {
        print("Error saving tokens: $e");
        return null;
      }

      // 이후 페이지 이동 및 데이터 초기화
      Get.to(() => Navigation());
      await Get.find<ChatsHandler>().getAllData();
      await Get.find<PetHandler>().fetchPets(userEmail);
    } else {
      print("JWT tokens are null.");
    }

    return userCredential;
  } catch (e) {
    print("Google Sign-In Error: $e");
    return null;
  }
}

// 서버와 Firebase ID 토큰 인증
Future<Map<String, String>?> _authenticateWithServer(String idToken) async {
  String serverUrl = "$server/auth/auth/firebase"; // FastAPI 서버 URL

  try {
    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id_token": idToken}),
    );

    // 서버 응답 디버깅
    print("Server Response: ${response.body}");

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // 응답 데이터 유효성 검사
      if (responseData.containsKey('access_token') && responseData.containsKey('refresh_token')) {
        return {
          'accessToken': responseData['access_token'],
          'refreshToken': responseData['refresh_token'],
        };
      } else {
        print("Invalid server response: ${response.body}");
        return null;
      }
    } else {
      print("Server Authentication Failed: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error connecting to server: $e");
    return null;
  }
}



// query inserted google email from db to differentiate whether email is registered or not
  userloginCheckJSONData(email) async {
    var url = Uri.parse('$server/user/selectuser?id=$email');
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);
  }

  // insert the account information to mysql(db) (안창빈)
  userloginInsertData(String userEmail, String userName) async {
    var url = Uri.parse(
        '$server/user/insertuser?id=$userEmail&password=""&image=usericon.jpg&name=$userName&phone=""');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];

    if (result == 'OK') {
    } else {}
  }

  // 로그아웃 및 비우기
  signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    box.write('userEmail', "");
    Get.find<PetHandler>().clearPet();
    Get.find<ChatsHandler>().chatsClear();
    update();
  }
}

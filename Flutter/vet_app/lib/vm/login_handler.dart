import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vet_app/model/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:vet_app/view/navigation.dart';

class LoginHandler extends GetxController {
  final box = GetStorage();
  var userdata = <UserData>[].obs;
  var savedData = <UserData>[].obs;
  List data = [];
  String userEmail = '';
  String userName = '';

  // 로그인 상태 확인
  bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null &&
        getStoredEmail().isNotEmpty;
  }

  // GetStorage에서 저장된 이메일을 가져옴
  String getStoredEmail() {
    return box.read('userEmail') ?? '';
  }

  // 사용자 정보를 데이터베이스에서 쿼리
  queryUser(String userEmail) async {
    var url = Uri.parse('http://127.0.0.1:8000/user/select?id=$userEmail');
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

  // Google Sign in pop-up
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // 로그인 취소 시 null 반환
    if (gUser == null) {
      return null;
    }

    // Google 로그인 정보 획득
    final GoogleSignInAuthentication googleAuth = await gUser.authentication;

    userEmail = gUser.email;
    userName = gUser.displayName!;

    // 이메일 정보를 저장
    box.write('userEmail', userEmail);
    box.write('userName', userName);

    // MySQL에서 계정 등록 여부 확인
    bool isUserRegistered = await checkDatabase(userEmail);

    // MySQL에 계정이 없으면 새로 등록
    if (!isUserRegistered) {
      await insertData(userEmail, userName);
    }

    // Firebase 인증 처리
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // 로그인 후 메인 화면으로 이동
    Get.to(() => Navigation(), arguments: [userEmail, userName]);

    return userCredential;
  }

  // 데이터베이스에서 사용자 존재 여부 확인
  Future<bool> checkDatabase(String email) async {
    await checkJSONData(email);
    return data.isNotEmpty;
  }

  // MySQL 데이터 확인
  checkJSONData(String email) async {
    var url = Uri.parse('http://127.0.0.1:8000/user/select?id=$email');
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);
  }

  // MySQL에 새로운 사용자 데이터 삽입
  insertData(String userEmail, String userName) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/user/insert?id=$userEmail&password=""&image=""&name=$userName');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];

    if (result == 'OK') {
      return "ok";
    }
  }
}

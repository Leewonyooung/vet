import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vet_app/model/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:vet_app/view/navigation.dart';
import 'package:vet_app/vm/chat_handler.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/user_handler.dart';

class LoginHandler extends UserHandler {
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

  signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final identityToken = appleCredential.identityToken;
      final userIdentifier = appleCredential.userIdentifier;

      // 첫 로그인 시 이메일과 이름 저장
      String? email = appleCredential.email;
      String? gname = appleCredential.givenName;
      String? fname = appleCredential.familyName;

      if (email != null && gname != null && fname != null) {
        // 첫 로그인: 이메일과 이름을 저장
        userName = '$fname$gname';
        box.write('userEmail', email);
        box.write('userName', userName);
        box.write('savedName', userName);
        box.write('saved', email);
        await userloginInsertData(email, userName);
      } else {
        box.write('userEmail', box.read('saved'));
        box.write('userName', box.read('savedName'));
        userName = box.read('userName');
      }

      final response = await http.post(
        Uri.parse("$server/auth/apple"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identity_token': identityToken,
          'user_identifier': userIdentifier,
          'email': box.read('userEmail'), // 서버로 저장된 이메일 전송
        }),
      );

      if (response.statusCode == 200) {

        final OAuthCredential credential =
            OAuthProvider('apple.com').credential(
          idToken: identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        Get.to(() => Navigation());
        await Get.find<ChatsHandler>().getAllData();
        await Get.find<PetHandler>().fetchPets(box.read('userEmail'));
      }
    } catch (e) {
      return 'Error during Apple Sign-In: $e';
    }
  }



  // Google Sign in pop up (안창빈)
  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // to prevent the error whitch when user return to the login page without signing in (안창빈)
    if (gUser == null) {
      return null;
    }

    // Obtain the auth details from the request (안창빈)
    final GoogleSignInAuthentication googleAuth = await gUser.authentication;

    userEmail = gUser.email;
    userName = gUser.displayName!;
    box.write('userEmail', userEmail);
    box.write('userName', userName);

    // check whether the account is registered (안창빈)
    bool isUserRegistered = await userloginCheckDatabase(userEmail);

    // if the account is trying to login on the first time add the google account information to the mySQL DB (안창빈)
    if (!isUserRegistered) {
      userloginInsertData(userEmail, userName);
    }

    // firbase Create a new credential (안창빈)
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credentials (안창빈)
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Navigate to Navigation page after successful sign-in (안창빈)
    Get.to(() => Navigation());
    await Get.find<ChatsHandler>().getAllData();
    // 로그인 성공 후 반려동물 정보 불러오기
    await Get.find<PetHandler>().fetchPets(getStoredEmail());

    // print(userCredential);
    // Return the UserCredential after successful sign-in (안창빈)
    return userCredential;
  }

  // check whether the account is registered (안창빈)
  userloginCheckDatabase(String email) async {
    userloginCheckJSONData(email);
    if (data.isEmpty) {
      return false;
    } else {
      return true;
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

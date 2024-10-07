import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vet_app/model/userdata.dart';
import 'package:vet_app/view/navigation.dart';
import 'package:http/http.dart' as http;
import 'package:vet_app/view/test.dart';

class LoginHandler extends GetxController{
  final box = GetStorage();
  var userdata = <UserData>[].obs;
  var savedData = <UserData>[].obs;
  List data = [];
  String userEmail = '';
  String userName = '';
  

  queryUser(userEmail) async{
    var url = Uri.parse('http://127.0.0.1:8000/select?id=$userEmail');
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

      savedData.add(UserData(
        id: id, 
        password: password, 
        image: image, 
        name: name
        ));
  }

  // Google Sign in pop up
  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // to prevent the error whitch when user return to the login page without signing in
    if (gUser == null) {
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await gUser.authentication;

    userEmail = gUser.email;
    userName = gUser.displayName!;
    print(userEmail);
    print(userName);
    // check whether the account is registered 
    bool isUserRegistered = await checkDatabase(userEmail);
    print(isUserRegistered);
    // if the account is trying to login on the first time add the google account information to the mySQL DB
    if (!isUserRegistered){      
      insertData(userEmail, userName!);
    }

    // firbase Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credentials
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Navigate to Navigation page after successful sign-in
    if (userCredential != null) {
      Get.to(Test(), arguments: [userEmail, userName]); // Navigate to home page
    }
    // print(userCredential);
      // Return the UserCredential after successful sign-in
    return userCredential;
  }


  checkDatabase(String email)async{
    checkJSONData(email);
    if (data.isEmpty){
      return false;
    }else{
      return true;
    }
  }

  checkJSONData(email)async{
    var url = Uri.parse('http://127.0.0.1:8000/select?id=$email');
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);

    // if (result.isNotEmpty){
    //   List<UserData> returnResult = [];
    //   String id = result[0]['id'];
    //   String password = result[0]['password'];
    //   String image = result[0]['image'];
    //   String name = result[0]['name'];

    //   returnResult.add(UserData(
    //     id: id, 
    //     password: password, 
    //     image: image, 
    //     name: name
    //     ));
    //   userdata.value = returnResult;

    // }
  }

  insertData(String userEmail, String userName)async{
    var url = Uri.parse('http://127.0.0.1:8000/insert?id=$userEmail&password=""&image=${Image.asset('images/usericon.png')}&name=$userName');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];

    if(result == 'OK'){
      // List<UserData> returnResult = [];
      // String id = result[0]['id'];
      // String password = result[0]['password'];
      // String image = result[0]['image'];
      // String name = result[0]['name'];

      // returnResult.add(UserData(
      //   id: id, 
      //   password: password, 
      //   image: image, 
      //   name: name
      //   ));
      // userdata.value = returnResult;
      print('ok');
    }else{
      print('no');
    }
  }
}

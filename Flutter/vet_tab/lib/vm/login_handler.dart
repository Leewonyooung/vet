import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vet_tab/model/clinic_login.dart';
import 'package:vet_tab/view/mgt_home.dart';
import 'package:vet_tab/vm/image_handler.dart';

class LoginHandler extends ImageHandler {
  final box = GetStorage();
  var isObscured = true.obs;

  //////////////////////////// Clinic & MGT /////////////////////////////

  ///Login MGT (안창빈)

  int tapCount = 0;

  mgtLogin() {
    tapCount++;
    if (tapCount == 7) {
      showMGTloginDialog();
    }
  }

  showMGTloginDialog() {
    Get.defaultDialog(
      title: '경고',
      content: const SizedBox(
          height: 75,
          width: 250,
          child: Text(
            '관리자 페이지로이동\n하시겠습니까?',
            style: TextStyle(fontSize: 20),
          )),
      barrierDismissible: false,
      textConfirm: '계속',
      onConfirm: () {
        tapCount = 0;
        Get.back();
        Get.to(() => MgtHome());
      },
      textCancel: '뒤로가기',
      onCancel: () {
        tapCount = 0;
        Get.back();
      },
    );
  }

  // Clinic login & check whether account trying to login is registerd in our db (안창빈)

  var cliniclogindata = <ClinicLogin>[].obs;

  clinicloginJsonCheck(String id, String password) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/user/selectclinic?id=$id&password=$password');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];

    if (result.isEmpty) {
      return result;
    } else {
      // List<ClinicLogin> returnResult = [];
      String id = result[0]['id'];
      String password = result[0]['password'];

      cliniclogindata.add(ClinicLogin(id: id, password: password));
      box.write('id', id);
      return result;
    }
  }

  // toggle password visibility
  togglePasswordVisibility() {
    isObscured.value = !isObscured.value;
  }

  // Clinic Password random Generator
  randomPasswordNumberClinic() {
    const String upperCaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowerCaseLetters = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String specialChars = r'!@#$%^&*()?_~';
    String includeAllChar =
        upperCaseLetters + lowerCaseLetters + numbers + specialChars;
    Random random = Random();
    String passwordClinic = '';

    passwordClinic += upperCaseLetters[random.nextInt(upperCaseLetters.length)];
    passwordClinic += lowerCaseLetters[random.nextInt(lowerCaseLetters.length)];
    passwordClinic += numbers[random.nextInt(numbers.length)];
    passwordClinic += specialChars[random.nextInt(specialChars.length)];
    for (int i = 0; i < 4; i++) {
      passwordClinic += includeAllChar[random.nextInt(includeAllChar.length)];
    }

    List<String> passwordClinicShuffle = passwordClinic.split('')..shuffle();
    return passwordClinicShuffle.join('');
  }



  logout()async{
    Get.back();
    box.write('id', "");
  }
}

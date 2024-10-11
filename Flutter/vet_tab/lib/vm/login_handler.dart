import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:http/http.dart' as http;
import 'package:vet_tab/model/clinic_login.dart';
import 'package:vet_tab/view/mgt_home.dart';
import 'package:vet_tab/vm/location_handler.dart';



class LoginHandler extends LocationHandler {
final box = GetStorage();
var isObscured = true.obs;


  //////////////////////////// Clinic & MGT /////////////////////////////

  ///Login MGT (안창빈)
  
  int tapCount = 0;
  
  mgtLogin(){
    tapCount ++;
    if (tapCount == 7){
      showMGTloginDialog();
    }
  }

  showMGTloginDialog(){
    Get.defaultDialog(
      title: 'Alert',
      content: const SizedBox( 
        height: 75,
        width: 250,
        child:  Text('Are you going proceed to Management page?',style: TextStyle(fontSize: 20),)),
      barrierDismissible: false,
      textConfirm: 'proceed',
      onConfirm: () {
        tapCount = 0;
        Get.back();
        Get.to(() => const MgtHome());
      },
      textCancel: 'Cencel',
      onCancel: () {
        tapCount = 0;
        Get.back();
      },
    );
  }

  ///Login Clinic (안창빈)

  var cliniclogindata = <ClinicLogin>[].obs;

  clincgetJSONData() async {
    cliniclogindata.clear();
    var url = Uri.parse('http://127.0.0.1:8000/user/selectclinic');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];

    List<ClinicLogin> returnResult = [];
    String id = results[0]['id'];
    String password = results[0]['password'];

    returnResult.add(ClinicLogin(id: id, password: password));
    box.write('id', id);

    cliniclogindata.value = returnResult;
  }
  // check whether account trying to login is registerd in our db (안창빈)

  clinicloginJsonCheck(String id, String password) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/user/selectclinic?id=$id&password=$password');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    return result;
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
  String includeAllChar = upperCaseLetters + lowerCaseLetters + numbers + specialChars;
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
}

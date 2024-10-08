import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/mgt_home.dart';
import 'package:vet_app/vm/vm_handler.dart';

class ClinicLogin extends StatelessWidget {
  ClinicLogin({super.key});

  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vmHandler = Get.put(VmHandler());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),

      body: GetBuilder<VmHandler>(
        builder: (controller) {
          return Center(
            child: Column(
              children: [
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText: '아이디를 입력하세요'
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호를 입력하세요'
                  ),
                ),
                  ElevatedButton(
                  onPressed: () => clinicloginJsonCheck(vmHandler), 
                  child: const Text('입력'),
                ),
              ],
            ),
          );
        },
      )
    );
  }
  //Function
  clinicloginJsonCheck(VmHandler vmHandler) async {
    String id =idController.text.trim();
    String password =passwordController.text.trim();

    List results = 
      await vmHandler.clinicloginJsonCheck(id, password);
    if (results.isEmpty){
      errorDialog();
    }else{
      loginDialog();
    }
  }
  
  errorDialog(){
    Get.defaultDialog(
      title: 'error',
      content : const Text('please contact management to create your clinic account \n TEL: 010-3116-9966'),
      textCancel: 'cancel',
      onCancel: Get.back,
    );
  }

  loginDialog(){
        Get.defaultDialog(
      title: 'Welcome',
      content : const Text('Login Successful'),
      barrierDismissible: false,
      textConfirm: 'proceed',
      onConfirm: () {
        idController.clear();
        passwordController.clear();
        Get.back();
        Get.to(()=> const MgtHome());
      },
    );
  }

}// END
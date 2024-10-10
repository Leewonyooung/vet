import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/mgt_home.dart';
import 'package:vet_app/vm/login_handler.dart';

class ClinicLogin extends StatelessWidget {
  ClinicLogin({super.key});

  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final vmHandler = Get.put(LoginHandler());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: GetBuilder<LoginHandler>(
          builder: (controller) {
            return Obx((){ 
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 300, 0, 50),
                      child: Text('Login',style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 500,
                        child: TextField(
                          controller: idController,
                          decoration: const InputDecoration(
                            labelText: '아이디를 입력하세요',
                            border: OutlineInputBorder()
                            ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 500,
                        child: TextField(
                          controller: passwordController,
                          obscureText: vmHandler.isObscured.value,
                          decoration: InputDecoration(
                            labelText: '비밀번호를 입력하세요',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () {
                                vmHandler.togglePasswordVisibility();
                              }, 
                              icon: Icon(vmHandler.isObscured.value ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: () => clinicloginJsonCheck(vmHandler),
                        child: const Text('login'),
                      ),
                    ),
                  ],
                ),
              ),
            );
            }
            );
          },
        ));
  }

  //Function
  clinicloginJsonCheck() async {
    String id = idController.text.trim();
    String password = passwordController.text.trim();

    List results = await vmHandler.clinicloginJsonCheck(id, password);
    if (results.isEmpty) {
      errorDialog();
    } else {
      loginDialog();
    }
  }

  errorDialog() {
    Get.defaultDialog(
      title: 'error',
      content: const Text(
          'please contact management to create your clinic account \n TEL: 010-3116-9966'),
      textCancel: 'cancel',
      onCancel: Get.back,
    );
  }

  loginDialog() {
    Get.defaultDialog(
      title: 'Welcome',
      content: const Text('Login Successful'),
      barrierDismissible: false,
      textConfirm: 'proceed',
      onConfirm: () {
        idController.clear();
        passwordController.clear();
        Get.back();
        Get.to(() => const MgtHome());
      },
    );
  }
}// END
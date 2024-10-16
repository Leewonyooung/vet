import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_tab/view/rail_home.dart';
import 'package:vet_tab/vm/login_handler.dart';

class ClinicLogin extends StatelessWidget {
  ClinicLogin({super.key});

  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final loginHandler = Get.put(LoginHandler());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 화면을 탭하면 키보드를 닫음
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Clinic Login',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 500,
                  child: TextField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: '아이디를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 500,
                  child: TextField(
                    controller: passwordController,
                    obscureText: loginHandler.isObscured.value,
                    decoration: InputDecoration(
                      labelText: '비밀번호를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        onPressed: () {
                          loginHandler.togglePasswordVisibility();
                        },
                        icon: Icon(
                          loginHandler.isObscured.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => clinicloginJsonCheck(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function
  clinicloginJsonCheck() async {
    String id = idController.text.trim();
    String password = passwordController.text.trim();

    List results = await loginHandler.clinicloginJsonCheck(id, password);
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
          '병원정보가 정확하지 않습니다. \n병원을 등록하지 않으셨다면 하기 전화번호로 문의 부탁드립니다 \n TEL: 010-3116-9966'),
      textCancel: 'cancel',
      onCancel: Get.back,
    );
  }

  loginDialog() {
    Get.defaultDialog(
      title: '환영합니다',
      content: const Text('로그인을 성공하셨습니다'),
      barrierDismissible: false,
      textConfirm: '확인',
      onConfirm: () {
        idController.clear();
        passwordController.clear();
        Get.back();
        Get.to(() => RailHome());
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/login_handler.dart';

class ClinicLogin extends StatelessWidget {
  ClinicLogin({super.key});

  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginHandler vmHandler = Get.put(LoginHandler());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('병원 로그인'),
        backgroundColor: Colors.green.shade400,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.1,
              vertical: screenHeight * 0.1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                _buildTextField(
                  controller: idController,
                  labelText: '아이디를 입력하세요',
                  isObscured: false,
                ),
                SizedBox(height: screenHeight * 0.02),
                Obx(() {
                  return _buildTextField(
                    controller: passwordController,
                    labelText: '비밀번호를 입력하세요',
                    isObscured: vmHandler.isObscured.value,
                    suffixIcon: IconButton(
                      onPressed: () {
                        vmHandler.isObscured.value =
                            !vmHandler.isObscured.value;
                      },
                      icon: Icon(
                        vmHandler.isObscured.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  );
                }),
                SizedBox(height: screenHeight * 0.05),
                ElevatedButton(
                  onPressed: () => clinicloginJsonCheck(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool isObscured = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  // Functionality remains the same
  clinicloginJsonCheck() async {
    // Add the logic for login validation here
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
        // Navigate to the next page if necessary
      },
    );
  }
}

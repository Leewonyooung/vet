import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vet_app/vm/login_handler.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final LoginHandler loginhandler = Get.find();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '로그인',
          style: TextStyle(fontSize: screenWidth * 0.05),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  await loginhandler.signInWithGoogle();
                },
                child: Image.asset(
                  'images/web_light_rd_SI@1x.png',
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.1,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              SignInWithAppleButton(
                onPressed: () async {
                  await loginhandler.signInWithApple();
                },
                style: SignInWithAppleButtonStyle.black,
                height: screenHeight * 0.07,
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

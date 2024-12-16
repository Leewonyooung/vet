import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vet_app/vm/login_handler.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final LoginHandler loginhandler = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                await LoginHandler().signInWithGoogle();
              },
              child: Image.asset('images/web_light_rd_SI@1x.png'),
            ),
            SignInWithAppleButton(
              onPressed: () async {
                await LoginHandler().signInWithApple();
              },
            ),
          ],
        ),
      ),
    );
  }
}

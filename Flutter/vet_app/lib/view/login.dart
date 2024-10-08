import 'package:flutter/material.dart';
import 'package:vet_app/vm/login_handler.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('title'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () async {
                  await LoginHandler().signInWithGoogle();
                },
                child: Image.asset('images/web_light_rd_SI@1x.png')),
          ],
        ),
      ),
    );
  }
}

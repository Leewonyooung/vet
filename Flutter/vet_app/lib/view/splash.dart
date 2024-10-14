import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/navigation.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    goScreen();
  }

  goScreen() async {
    await Future.delayed(
        const Duration(seconds: 2), () => Get.to(Navigation()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('images/pet_splash.gif')),
    );
  }
}

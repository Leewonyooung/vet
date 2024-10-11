import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QueryReservation extends StatelessWidget {
  QueryReservation({super.key});
  var value = Get.arguments;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약내역'),
      ),
    );
  }
}
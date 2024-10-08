import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/user_handler.dart';

class MyinfoUpdate extends StatelessWidget {
  MyinfoUpdate({super.key});

  final TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final UserHandler userHandler = Get.put(UserHandler());
    var value = Get.arguments;
    nameController.text = value[1];
    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 정보 수정'),
      ),
      body: GetBuilder<UserHandler>(
        builder: (controller) {
          return Center(
            child: Column(
              children: [
                  Image.asset(value[2],
                  width: 100,
                  height: 100,
                  ), //3: image
                  Text("ID : ${value[0]}"),
                  TextField(
                    controller: nameController,
                  ),
                  ElevatedButton(
                    onPressed: () {
                  }, 
                  child: const Text('저장')
                  )
              ],
            ),
          );
        },
        ),

    );
  }


  
}
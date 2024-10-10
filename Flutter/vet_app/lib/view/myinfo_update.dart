
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/user_handler.dart';

class MyinfoUpdate extends StatelessWidget {
  MyinfoUpdate({super.key});

  final TextEditingController nameController = TextEditingController();
  final LoginHandler loginHandler = Get.put(LoginHandler());
  @override
  Widget build(BuildContext context) {
    final UserHandler userHandler = Get.find();
    var value = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 정보 수정'),
      ),
      body: GetBuilder<UserHandler>(
        builder: (controller) {
          return FutureBuilder(
            future: userHandler.selectMyinfo(value),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator());
              }else if(snapshot.hasError){
                return Center(child: Text("${snapshot.error}"));
              }else{
                final result = userHandler.mypageUserInfo[0];
                nameController.text = result.name;
              return Obx(
              () {
              return Center(
                child: Column(
                  children: [
                    Image.asset(
                      result.image,
                      width: 100,
                      height: 100,
                    ), 
                    Text("ID : ${result.id}"),
                    TextField(
                      controller: nameController,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        //
                      }, 
                      child: const Text('저장')
                      )
                  ],
                ),
              );
              }
            );
            }
            }
          );
        },
      ),
  
    );
  }
}

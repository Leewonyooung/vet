import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/user_handler.dart';

class MyinfoUpdate extends StatelessWidget {
  MyinfoUpdate({super.key});

  final TextEditingController nameController = TextEditingController();
  final LoginHandler loginHandler = Get.put(LoginHandler());
  @override
  Widget build(BuildContext context) {
    // final UserHandler userHandler = Get.find();
    final UserHandler userHandler = Get.put(UserHandler());
    var value = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 정보 수정'),
      ),
      body: GetBuilder<UserHandler>(
        builder: (_) {
          return FutureBuilder(
              future: userHandler.selectMyinfo(value),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("${snapshot.error}"));
                } else {
                  final result = userHandler.mypageUserInfo[0];
                  nameController.text = result.name;
                  return Center(
                    child: Column(
                      children: [
                        GestureDetector(
                            onTap: () => userHandler
                                .getImageFromGalleryEdit(ImageSource.gallery),
                            child: userHandler.imageFile == null
                                ? Stack(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.4,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          child: Image.network(
                                            "http://127.0.0.1:8000/mypage/view/${result.image}",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      PositionedDirectional(
                                        start:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                                0.001,
                                        child:  Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 45,
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      )
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.4,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          child: Image.file(
                                            File(userHandler.imageFile!.path),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      PositionedDirectional(
                                        start:
                                            MediaQuery.of(context).size.width *
                                                0.62,
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                                0.001,
                                        child:  Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 45,
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      )
                                    ],
                                  )
                                  ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "이메일 : ${result.id}",
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: TextField(
                              controller: nameController,
                              maxLength: 45,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20))),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) {
                              errorSnackBar(
                                  '경고', '이름을 입력하세요', SnackPosition.TOP);
                            } else {
                              if (userHandler.firstDisp == 0) {
                                nameUpdateAction(userHandler, result.id!);
                              } else {
                                allUpdateAction(
                                    userHandler, result.image, result.id!);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.8,
                                  MediaQuery.of(context).size.height * 0.055)),
                          child: const Text(
                            '저장',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              });
        },
      ),
    );
  }

  //ff
  //이름만 수정할때
  nameUpdateAction(UserHandler userHandler, String userid) async {
    String name = nameController.text.trim();
    String id = userid;
    var updateResult = await userHandler.updateUserName(name, id);
    if (updateResult == 'ok') {
      okShowDialog();
    } else {
      errorSnackBar('경고', '수정에 실패했습니다.', SnackPosition.BOTTOM);
    }
  }

  // 이름, 이미지 모두 수정할때
  allUpdateAction(UserHandler userHandler, String image, String userid) async {
    await userHandler.deleteUserImage(image);
    await userHandler.uploadUserImage();
    var updateResult = await userHandler.updateUserAll(
        nameController.text.trim(), userHandler.filename, userid);
    if (updateResult == 'ok') {
      okShowDialog();
    } else {
      errorSnackBar('경고', '수정에 실패했습니다', SnackPosition.BOTTOM);
    }
  }

// 수정확인 다이얼로그
  okShowDialog() {
    Get.defaultDialog(title: '수정성공', middleText: '수정이 완료되었습니다.', actions: [
      ElevatedButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: const Text('확인')),
    ]);
  }

  // error 스낵바
  // 제목, 메세지, 스낵포지션
  errorSnackBar(String title, String message, SnackPosition position) {
    Get.snackbar(title, message,
        backgroundColor: Colors.red,
        colorText: Colors.black,
        duration: const Duration(seconds: 2),
        snackPosition: position);
  }
}

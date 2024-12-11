import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/user_handler.dart';

class MyinfoUpdate extends StatelessWidget {
  MyinfoUpdate({super.key});

  final TextEditingController nameController = TextEditingController();
  final LoginHandler loginHandler = Get.find();

  @override
  Widget build(BuildContext context) {
    var value = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '계정 정보 수정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: GetBuilder<LoginHandler>(
        builder: (_) {
          return FutureBuilder(
            future: loginHandler.selectMyinfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("${snapshot.error}"));
              } else {
                final result = loginHandler.mypageUserInfo[0];
                nameController.text = result.name;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileImage(context, loginHandler, result),
                        const SizedBox(height: 30),
                        _buildEmailInfo(result),
                        const SizedBox(height: 20),
                        _buildNameField(),
                        const SizedBox(height: 30),
                        _buildSaveButton(context, loginHandler, result),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  _buildProfileImage(
      BuildContext context, UserHandler userHandler, dynamic result) {
    return Center(
      child: GestureDetector(
        onTap: () => userHandler.getImageFromGalleryEdit(ImageSource.gallery),
        child: Stack(
          children: [
           CircleAvatar(
            radius: 80,
            backgroundImage: userHandler.imageFile == null
                ? NetworkImage("${userHandler.server}/mypage/view/${result.image}") 
                : FileImage(File(userHandler.imageFile!.path)) as ImageProvider,
            child: userHandler.imageFile == null
                ? CachedNetworkImage(
                    imageUrl: "${userHandler.server}/mypage/view/${result.image}",
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                : null,
          ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildEmailInfo(dynamic result) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.email,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "이메일: ${result.id}",
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildNameField() {
    return TextField(
      controller: nameController,
      maxLength: 45,
      decoration: InputDecoration(
        labelText: '이름',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
      ),
    );
  }

  _buildSaveButton(
      BuildContext context, UserHandler userHandler, dynamic result) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (nameController.text.trim().isEmpty) {
            errorSnackBar(
              '경고',
              '이름을 입력하세요',
              SnackPosition.TOP,
            );
          } else {
            if (userHandler.firstDisp == 0) {
              nameUpdateAction(userHandler, result.id!);
            } else {
              allUpdateAction(userHandler, result.image, result.id!);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightGreen.shade300,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          '저장',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  //이름만 수정할때
  nameUpdateAction(UserHandler userHandler, String userid) async {
    String name = nameController.text.trim();
    String id = userid;
    var updateResult = await userHandler.updateUserName(name, id);
    if (updateResult == 'ok') {
      okShowDialog();
    } else {
      errorSnackBar(
        '경고',
        '수정에 실패했습니다.',
        SnackPosition.BOTTOM,
      );
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
      errorSnackBar(
        '경고',
        '수정에 실패했습니다',
        SnackPosition.BOTTOM,
      );
    }
  }

// 수정확인 다이얼로그
  okShowDialog() {
    Get.defaultDialog(
      title: '수정성공',
      middleText: '수정이 완료되었습니다.',
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: const Text('확인'),
        ),
      ],
    );
  }

  // error 스낵바
  // 제목, 메세지, 스낵포지션
  errorSnackBar(String title, String message, SnackPosition position) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.black,
      duration: const Duration(seconds: 2),
      snackPosition: position,
    );
  }
}

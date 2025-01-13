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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '계정 정보 수정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: screenWidth * 0.05,
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
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileImage(
                            context, loginHandler, result, screenWidth),
                        SizedBox(height: screenHeight * 0.04),
                        _buildEmailInfo(result, screenWidth),
                        SizedBox(height: screenHeight * 0.03),
                        _buildNameField(screenWidth),
                        SizedBox(height: screenHeight * 0.05),
                        _buildSaveButton(
                            context, loginHandler, result, screenWidth),
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

  Widget _buildProfileImage(BuildContext context, UserHandler userHandler,
      dynamic result, double screenWidth) {
    return Center(
      child: GestureDetector(
        onTap: () => userHandler.getImageFromGalleryEdit(ImageSource.gallery),
        child: Stack(
          children: [
            ClipOval(
              child: CircleAvatar(
                radius: screenWidth * 0.2,
                backgroundImage: userHandler.imageFile == null
                    ? NetworkImage(
                        "${userHandler.server}/mypage/view/${result.image}")
                    : FileImage(File(userHandler.imageFile!.path))
                        as ImageProvider,
                child: userHandler.imageFile == null
                    ? CachedNetworkImage(
                        imageUrl:
                            "${userHandler.server}/mypage/view/${result.image}",
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : null,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: const BoxDecoration(
                  color: Colors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: screenWidth * 0.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailInfo(dynamic result, double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            Icon(
              Icons.email,
              color: Colors.grey[600],
              size: screenWidth * 0.06,
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Text(
                "이메일: ${result.id}",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField(double screenWidth) {
    return TextField(
      controller: nameController,
      maxLength: 45,
      decoration: InputDecoration(
        labelText: '이름',
        labelStyle: TextStyle(fontSize: screenWidth * 0.045),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, UserHandler userHandler,
      dynamic result, double screenWidth) {
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
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
        ),
        child: Text(
          '저장',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
          ),
        ),
      ),
    );
  }

  // 이름만 수정할 때
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

  // 이름, 이미지 모두 수정할 때
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

  // 수정 성공 다이얼로그
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

  // 에러 스낵바
  errorSnackBar(String title, String message, SnackPosition position) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: position,
    );
  }
}

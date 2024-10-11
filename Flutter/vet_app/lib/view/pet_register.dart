import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/model/pet.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PetRegister extends StatefulWidget {
  const PetRegister({super.key});

  @override
  _PetRegisterState createState() => _PetRegisterState();
}

class _PetRegisterState extends State<PetRegister> {
  final PetHandler petHandler = Get.put(PetHandler());
  final LoginHandler loginHandler = Get.find<LoginHandler>();

  final TextEditingController idController = TextEditingController();
  final TextEditingController speciesTypeController = TextEditingController();
  final TextEditingController speciesCategoryController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController featuresController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  File? imageFile;
  final ImagePicker picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('반려동물 등록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: speciesTypeController,
              decoration: const InputDecoration(labelText: '종류'),
            ),
            TextField(
              controller: speciesCategoryController,
              decoration: const InputDecoration(labelText: '세부 종류'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: birthdayController,
              decoration: const InputDecoration(labelText: '생일'),
            ),
            TextField(
              controller: featuresController,
              decoration: const InputDecoration(labelText: '특징'),
            ),
            TextField(
              controller: genderController,
              decoration: const InputDecoration(labelText: '성별'),
            ),
            const SizedBox(height: 20),
            // 이미지 선택 버튼
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("이미지 선택"),
            ),
            const SizedBox(height: 20),
            // 이미지 미리보기
            imageFile != null
                ? Image.file(imageFile!, height: 200, width: 200)
                : const Text("선택된 이미지 없음"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String userId =
                    loginHandler.getStoredEmail(); // 로그인된 사용자의 이메일 가져오기

                if (userId.isEmpty) {
                  Get.snackbar('오류', '로그인이 필요합니다.');
                  return;
                }

                String id = idController.text;
                String speciesType = speciesTypeController.text;
                String speciesCategory = speciesCategoryController.text;
                String name = nameController.text;
                String birthday = birthdayController.text;
                String features = featuresController.text;
                String gender = genderController.text;

                Pet newPet = Pet(
                  id: id,
                  userId: userId,
                  speciesType: speciesType,
                  speciesCategory: speciesCategory,
                  name: name,
                  birthday: birthday,
                  features: features,
                  gender: gender,
                  image: imageFile?.path, // 이미지 파일 경로 전달
                );

                bool success = await petHandler.addPet(newPet, imageFile);
                if (success) {
                  Get.back();
                  Get.snackbar('등록 완료', '반려동물이 성공적으로 등록되었습니다.');
                } else {
                  Get.snackbar('등록 실패', '반려동물 등록에 실패했습니다.');
                }
              },
              child: const Text('등록하기'),
            ),
          ],
        ),
      ),
    );
  }
}

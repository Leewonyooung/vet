import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/model/pet.dart';

class PetRegister extends StatelessWidget {
  PetRegister({super.key});

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
  final TextEditingController imageController = TextEditingController();

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
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: '이미지 URL (선택)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 로그인한 사용자의 ID(email)를 사용
                String userId = loginHandler.getStoredEmail(); // 저장된 이메일 가져오기
                if (userId.isEmpty) {
                  Get.snackbar('오류', '로그인이 필요합니다.'); // 로그인되지 않은 경우 처리
                  return;
                }

                // 입력 필드 값 가져오기
                String id = idController.text;
                String speciesType = speciesTypeController.text;
                String speciesCategory = speciesCategoryController.text;
                String name = nameController.text;
                String birthday = birthdayController.text;
                String features = featuresController.text;
                String gender = genderController.text;
                String image = imageController.text;

                // Pet 모델 생성
                Pet newPet = Pet(
                  id: id,
                  userId: userId, // 로그인된 사용자의 ID 사용
                  speciesType: speciesType,
                  speciesCategory: speciesCategory,
                  name: name,
                  birthday: birthday,
                  features: features,
                  gender: gender,
                  image: image,
                );

                // Pet 등록 핸들러 호출
                petHandler.addPet(newPet).then((success) {
                  if (success) {
                    Get.snackbar('등록 완료', '반려동물이 성공적으로 등록되었습니다.');
                    Get.back();
                  } else {
                    Get.snackbar('등록 실패', '반려동물 등록에 실패했습니다.');
                  }
                });
              },
              child: const Text('등록하기'),
            ),
          ],
        ),
      ),
    );
  }
}

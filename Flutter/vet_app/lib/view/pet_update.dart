import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/pet.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/species_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PetUpdate extends StatelessWidget {
  final Pet pet;

  PetUpdate({super.key, required this.pet});

  final SpeciesHandler speciesHandler = Get.put(SpeciesHandler());
  final PetHandler petHandler = Get.find<PetHandler>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController featuresController = TextEditingController();
  final RxString selectedGender = ''.obs;
  final Rx<File?> image = Rx<File?>(null);

  @override
  Widget build(BuildContext context) {
    // 기존 정보로 컨트롤러 초기화
    nameController.text = pet.name;
    idController.text = pet.id;
    birthdayController.text = pet.birthday;
    featuresController.text = pet.features;
    selectedGender.value = pet.gender;

    // 종류와 세부 종류 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      speciesHandler.setSpeciesType(pet.speciesType);
      speciesHandler.loadSpeciesCategories(pet.speciesType).then((_) {
        speciesHandler.setSpeciesCategory(pet.speciesCategory);
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('반려동물 정보 수정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'ID'),
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
                  value: speciesHandler.selectedSpeciesType.value,
                  items: speciesHandler.speciesTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    speciesHandler.setSpeciesType(newValue);
                    if (newValue != null) {
                      speciesHandler.loadSpeciesCategories(newValue).then((_) {
                        speciesHandler.setSpeciesCategory(null); // 세부 종류 초기화
                      });
                    }
                  },
                  decoration: const InputDecoration(labelText: '종류'),
                )),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
                  value: speciesHandler.selectedSpeciesCategory.value,
                  items:
                      speciesHandler.speciesCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    speciesHandler.setSpeciesCategory(newValue);
                  },
                  decoration: const InputDecoration(labelText: '세부 종류'),
                )),
            const SizedBox(height: 16),
            TextField(
              controller: birthdayController,
              decoration: const InputDecoration(labelText: '생일 (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: featuresController,
              decoration: const InputDecoration(labelText: '특징'),
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
                  value: selectedGender.value,
                  items: ['수컷', '암컷'].map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedGender.value = newValue;
                    }
                  },
                  decoration: const InputDecoration(labelText: '성별'),
                )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  image.value = File(pickedFile.path);
                }
              },
              child: const Text('이미지 선택'),
            ),
            Obx(() {
              if (image.value != null) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Image.file(image.value!, height: 200),
                  ],
                );
              } else if (pet.image?.isNotEmpty == true) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Image.network(
                      'http://127.0.0.1:8000/pet/uploads/${pet.image}',
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 200);
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    speciesHandler.selectedSpeciesType.value == null ||
                    speciesHandler.selectedSpeciesCategory.value == null ||
                    birthdayController.text.isEmpty ||
                    selectedGender.value.isEmpty) {
                  Get.snackbar('오류', '모든 필드를 입력해주세요.');
                  return;
                }

                final updatedPet = Pet(
                  id: pet.id,
                  userId: pet.userId,
                  name: nameController.text,
                  speciesType: speciesHandler.selectedSpeciesType.value!,
                  speciesCategory:
                      speciesHandler.selectedSpeciesCategory.value!,
                  birthday: birthdayController.text,
                  features: featuresController.text,
                  gender: selectedGender.value,
                  image: pet.image,
                );

                final success =
                    await petHandler.updatePet(updatedPet, image.value);
                if (success) {
                  Get.back(result: true);
                } else {
                  Get.snackbar('오류', '반려동물 정보 수정에 실패했습니다.');
                }
              },
              child: const Text('수정하기'),
            ),
          ],
        ),
      ),
    );
  }
}

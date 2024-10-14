import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/pet.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/species_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PetRegister extends StatelessWidget {
  PetRegister({super.key});

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
    speciesHandler.loadSpeciesTypes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('반려동물 등록'),
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
                  },
                  decoration: const InputDecoration(labelText: '종류'),
                  hint: const Text('종류를 선택하세요'),
                  isExpanded: true,
                  menuMaxHeight: 300,
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
                  hint: const Text('세부 종류를 선택하세요'),
                  isExpanded: true,
                  menuMaxHeight: 300,
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
                  value: selectedGender.value.isNotEmpty
                      ? selectedGender.value
                      : null,
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
                  hint: const Text('성별을 선택하세요'),
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
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    idController.text.trim().isEmpty ||
                    speciesHandler.selectedSpeciesType.value == null ||
                    speciesHandler.selectedSpeciesCategory.value == null ||
                    birthdayController.text.trim().isEmpty ||
                    selectedGender.value.isEmpty) {
                  Get.snackbar('오류', '모든 필드를 입력해주세요.');
                  return;
                }

                final newPet = Pet(
                  id: idController.text.trim(),
                  userId: petHandler.box.read('userEmail') ?? '',
                  name: nameController.text.trim(),
                  speciesType: speciesHandler.selectedSpeciesType.value!,
                  speciesCategory:
                      speciesHandler.selectedSpeciesCategory.value!,
                  birthday: birthdayController.text.trim(),
                  features: featuresController.text.trim(),
                  gender: selectedGender.value,
                  image: '',
                );

                final success = await petHandler.addPet(newPet, image.value);
                if (success) {
                  Get.back(result: true);
                } else {
                  Get.snackbar('오류', '반려동물 등록에 실패했습니다.');
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

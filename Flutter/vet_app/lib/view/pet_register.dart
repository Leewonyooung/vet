import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/pet.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/species_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class PetRegister extends StatelessWidget {
  PetRegister({super.key});

  final SpeciesHandler speciesHandler = Get.put(SpeciesHandler());
  final PetHandler petHandler = Get.find<PetHandler>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController featuresController = TextEditingController();

  // 성별 선택을 위한 변수
  final RxString selectedGender = ''.obs;
  // 이미지 파일을 위한 변수
  final Rx<File?> image = Rx<File?>(null);

  @override
  Widget build(BuildContext context) {
    // 종 목록 불러오기
    speciesHandler.loadSpeciesTypes();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '반려동물 등록',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 24),
            _buildTextField(
              nameController,
              '이름',
              Icons.pets,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              idController,
              'ID',
              Icons.badge,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              '종류',
              speciesHandler.selectedSpeciesType,
              speciesHandler.speciesTypes,
              (newValue) => speciesHandler.setSpeciesType(newValue),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              '세부 종류',
              speciesHandler.selectedSpeciesCategory,
              speciesHandler.speciesCategories,
              (newValue) => speciesHandler.setSpeciesCategory(newValue),
            ),
            const SizedBox(height: 16),
            _buildDatePicker(context),
            const SizedBox(height: 16),
            _buildTextField(
              featuresController,
              '특징',
              Icons.description,
            ),
            const SizedBox(height: 16),
            _buildGenderSelection(),
            const SizedBox(height: 32),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  // --- Functions ---

  // 이미지 선택
  _buildImagePicker() {
    return Obx(() {
      return Center(
        child: GestureDetector(
          onTap: () async {
            final pickedFile =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              image.value = File(pickedFile.path);
            }
          },
          child: CircleAvatar(
            radius: 80,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                image.value != null ? FileImage(image.value!) : null,
            child: image.value == null
                ? const Icon(
                    Icons.add_a_photo,
                    size: 40,
                    color: Colors.grey,
                  )
                : null,
          ),
        ),
      );
    });
  }

  // 텍스트 필드
  _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // 드롭다운 버튼
  _buildDropdown(String label, Rx<String?> selectedValue, List<String> items,
      Function(String?) onChanged) {
    return Obx(() => DropdownButtonFormField<String>(
          value: selectedValue.value,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          isExpanded: true,
          menuMaxHeight: 300,
        ));
  }

  // 날짜 선택
  _buildDatePicker(BuildContext context) {
    return TextField(
      controller: birthdayController,
      decoration: InputDecoration(
        labelText: '생일',
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          birthdayController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      },
    );
  }

  // 성별 선택
  _buildGenderSelection() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('수컷'),
                value: '수컷',
                groupValue: selectedGender.value,
                onChanged: (value) => selectedGender.value = value!,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('암컷'),
                value: '암컷',
                groupValue: selectedGender.value,
                onChanged: (value) => selectedGender.value = value!,
              ),
            ),
          ],
        ));
  }

  // 등록 버튼
  _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_validateInputs()) {
            final newPet = _createPet();
            final success = await petHandler.addPet(newPet, image.value);
            if (success) {
              Get.back(result: true);
            } else {
              Get.snackbar('오류', '반려동물 등록에 실패했습니다.');
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          '등록하기',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // 입력값 확인
  _validateInputs() {
    if (nameController.text.trim().isEmpty ||
        idController.text.trim().isEmpty ||
        speciesHandler.selectedSpeciesType.value == null ||
        speciesHandler.selectedSpeciesCategory.value == null ||
        birthdayController.text.trim().isEmpty ||
        selectedGender.value.isEmpty) {
      Get.snackbar(
        '오류',
        '모든 필드를 입력해주세요.',
      );
      return false;
    }
    return true;
  }

  // Pet 객체 생성
  _createPet() {
    return Pet(
      id: idController.text.trim(),
      userId: petHandler.box.read('userEmail') ?? '',
      name: nameController.text.trim(),
      speciesType: speciesHandler.selectedSpeciesType.value!,
      speciesCategory: speciesHandler.selectedSpeciesCategory.value!,
      birthday: birthdayController.text.trim(),
      features: featuresController.text.trim(),
      gender: selectedGender.value,
      image: '',
    );
  }
}

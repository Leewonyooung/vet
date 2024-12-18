import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/pet.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class PetRegister extends StatelessWidget {
  PetRegister({super.key});

  final PetHandler petHandler = Get.put(PetHandler());
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
    final screenWidth = MediaQuery.of(context).size.width;

    petHandler.loadSpeciesTypes(); // 종 목록 불러오기

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '반려동물 등록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(screenWidth),
            SizedBox(height: screenWidth * 0.06),
            _buildTextField(
              nameController,
              '이름',
              Icons.pets,
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.04),
            _buildTextField(
              idController,
              'ID',
              Icons.badge,
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.04),
            _buildDropdown(
              '종류',
              petHandler.selectedSpeciesType,
              petHandler.speciesTypes,
              (newValue) => petHandler.setSpeciesType(newValue),
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.04),
            _buildDropdown(
              '세부 종류',
              petHandler.selectedSpeciesCategory,
              petHandler.speciesCategories,
              (newValue) => petHandler.setSpeciesCategory(newValue),
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.04),
            _buildDatePicker(context, screenWidth),
            SizedBox(height: screenWidth * 0.04),
            _buildTextField(
              featuresController,
              '특징',
              Icons.description,
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.04),
            _buildGenderSelection(screenWidth),
            SizedBox(height: screenWidth * 0.08),
            _buildRegisterButton(screenWidth),
          ],
        ),
      ),
    );
  }

  // --- UI 위젯 ---

  // 이미지 선택 위젯
  Widget _buildImagePicker(double screenWidth) {
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
            radius: screenWidth * 0.2,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                image.value != null ? FileImage(image.value!) : null,
            child: image.value == null
                ? Icon(
                    Icons.add_a_photo,
                    size: screenWidth * 0.1,
                    color: Colors.grey,
                  )
                : null,
          ),
        ),
      );
    });
  }

  // 텍스트 필드 위젯
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    double screenWidth,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: screenWidth * 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // 드롭다운 버튼 위젯
  Widget _buildDropdown(
    String label,
    Rx<String?> selectedValue,
    List<String> items,
    Function(String?) onChanged,
    double screenWidth,
  ) {
    return Obx(() {
      return DropdownButtonFormField<String>(
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
      );
    });
  }

  // 날짜 선택 위젯
  Widget _buildDatePicker(BuildContext context, double screenWidth) {
    return TextField(
      controller: birthdayController,
      decoration: InputDecoration(
        labelText: '생일',
        prefixIcon: Icon(Icons.calendar_today, size: screenWidth * 0.06),
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

  // 성별 선택 위젯
  Widget _buildGenderSelection(double screenWidth) {
    return Obx(() {
      return Row(
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
      );
    });
  }

  // 등록 버튼 위젯
  Widget _buildRegisterButton(double screenWidth) {
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
          backgroundColor: Colors.lightGreen.shade300,
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          '등록하기',
          style: TextStyle(fontSize: screenWidth * 0.045),
        ),
      ),
    );
  }

  // --- 기능 ---

  // 입력값 유효성 검사
  bool _validateInputs() {
    if (nameController.text.trim().isEmpty ||
        idController.text.trim().isEmpty ||
        petHandler.selectedSpeciesType.value == null ||
        petHandler.selectedSpeciesCategory.value == null ||
        birthdayController.text.trim().isEmpty ||
        selectedGender.value.isEmpty) {
      Get.snackbar('오류', '모든 필드를 입력해주세요.');
      return false;
    }
    return true;
  }

  // Pet 객체 생성
  Pet _createPet() {
    return Pet(
      id: idController.text.trim(),
      userId: petHandler.box.read('userEmail') ?? '',
      name: nameController.text.trim(),
      speciesType: petHandler.selectedSpeciesType.value!,
      speciesCategory: petHandler.selectedSpeciesCategory.value!,
      birthday: birthdayController.text.trim(),
      features: featuresController.text.trim(),
      gender: selectedGender.value,
      image: '',
    );
  }
}

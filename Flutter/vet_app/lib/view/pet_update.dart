import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/pet.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/species_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
    // 기존 정보 가져오기
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
        title: const Text('반려동물 정보 수정', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 24),
            _buildTextField(nameController, '이름', Icons.pets),
            const SizedBox(height: 16),
            _buildTextField(idController, 'ID', Icons.badge),
            const SizedBox(height: 16),
            _buildDropdown('종류', speciesHandler.selectedSpeciesType,
                speciesHandler.speciesTypes, (newValue) {
              speciesHandler.setSpeciesType(newValue);
              if (newValue != null) {
                speciesHandler.loadSpeciesCategories(newValue).then((_) {
                  speciesHandler.setSpeciesCategory(null);
                });
              }
            }),
            const SizedBox(height: 16),
            _buildDropdown('세부 종류', speciesHandler.selectedSpeciesCategory,
                speciesHandler.speciesCategories, (newValue) {
              speciesHandler.setSpeciesCategory(newValue);
            }),
            const SizedBox(height: 16),
            _buildDatePicker(context),
            const SizedBox(height: 16),
            _buildTextField(featuresController, '특징', Icons.description),
            const SizedBox(height: 16),
            _buildGenderSelection(),
            const SizedBox(height: 32),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

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
            backgroundImage: image.value != null
                ? FileImage(image.value!)
                : (pet.image?.isNotEmpty == true
                    ? NetworkImage(
                            'http://127.0.0.1:8000/pet/uploads/${pet.image}')
                        as ImageProvider
                    : null),
            child: (image.value == null && pet.image?.isEmpty != false)
                ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                : null,
          ),
        ),
      );
    });
  }

  _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

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

  _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_validateInputs()) {
            final updatedPet = _createUpdatedPet();
            final success = await petHandler.updatePet(updatedPet, image.value);
            if (success) {
              Get.back(result: true);
            } else {
              Get.snackbar('오류', '반려동물 정보 수정에 실패했습니다.');
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
        child: const Text('수정하기', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  _validateInputs() {
    if (nameController.text.trim().isEmpty ||
        speciesHandler.selectedSpeciesType.value == null ||
        speciesHandler.selectedSpeciesCategory.value == null ||
        birthdayController.text.trim().isEmpty ||
        selectedGender.value.isEmpty) {
      Get.snackbar('오류', '모든 필드를 입력해주세요.');
      return false;
    }
    return true;
  }

  _createUpdatedPet() {
    return Pet(
      id: pet.id,
      userId: pet.userId,
      name: nameController.text.trim(),
      speciesType: speciesHandler.selectedSpeciesType.value!,
      speciesCategory: speciesHandler.selectedSpeciesCategory.value!,
      birthday: birthdayController.text.trim(),
      features: featuresController.text.trim(),
      gender: selectedGender.value,
      image: pet.image,
    );
  }
}

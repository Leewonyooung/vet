import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vet_tab/view/mgt_clinic_map.dart';
import 'package:vet_tab/vm/clinic_handler.dart';

class MgtClinicAdd extends StatelessWidget {
  MgtClinicAdd({super.key});

  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController longController = TextEditingController();
  final TextEditingController introController = TextEditingController();
  final TextEditingController stimeController = TextEditingController();
  final TextEditingController etimeController = TextEditingController();
  final clinicHandler = Get.put(ClinicHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '병원 추가',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          onPressed: () {
            clinicHandler.imageFile = null;
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: GetBuilder<ClinicHandler>(
        builder: (_) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: Column(
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 30),
                  _buildOperatingTimeSection(context),
                  const SizedBox(height: 30),
                  _buildClinicInfoSection(),
                  const SizedBox(height: 50),
                  _buildAddButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Container(
          width: 400,
          height: 300,
          color: Colors.grey[300],
          child: Center(
            child: clinicHandler.imageFile == null
                ? const Text('이미지가 선택되지 않았습니다')
                : Image.file(File(clinicHandler.imageFile!.path)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            clinicHandler.getImageFromGallery(ImageSource.gallery);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('이미지 가져오기'),
        ),
      ],
    );
  }

  Widget _buildOperatingTimeSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeTextField('영업시작', stimeController, true, context),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '~',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        _buildTimeTextField('영업종료', etimeController, false, context),
      ],
    );
  }

  Widget _buildTimeTextField(String label, TextEditingController controller,
      bool isStart, BuildContext context) {
    return SizedBox(
      width: 150,
      child: Obx(() {
        controller.text = isStart
            ? clinicHandler.startOpTime.value
            : clinicHandler.endOpTime.value;
        return TextField(
          onTap: () async {
            await clinicHandler.opDateSelection(context, isStart);
          },
          readOnly: true,
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        );
      }),
    );
  }

  Widget _buildClinicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('아이디', '아이디를 입력해주세요', idController),
        _buildTextField('비밀번호', '비밀번호를 입력해주세요', passwordController,
            isReadOnly: true,
            suffixIcon: IconButton(
              onPressed: () {
                passwordController.clear();
                passwordController.text =
                    clinicHandler.randomPasswordNumberClinic();
              },
              icon: const Icon(Icons.add_outlined),
            )),
        _buildTextField('병원이름', '병원이름을 입력해주세요', nameController),
        _buildTextField('전화번호', '전화번호를 입력해주세요', telController),
        _buildAddressSection(),
        _buildTextField('설명', '설명을 입력하세요', introController, maxLines: 4),
      ],
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {bool isReadOnly = false, int maxLines = 1, Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField('주소', '주소를 입력해주세요', addressController,
              suffixIcon: IconButton(
                onPressed: () {
                  clinicHandler.updateAddress(addressController.text);
                  Get.to(() => const MgtClinicMap(),
                          arguments: addressController.text)
                      ?.then((value) {
                    if (value != null) {
                      updateClinicAddressData(
                          value['address'], value['lat'], value['long']);
                    }
                  });
                },
                icon: const Icon(Icons.search),
              )),
        ),
        const SizedBox(width: 20),
        _buildCoordinateFields('위도', latController),
        const SizedBox(width: 10),
        _buildCoordinateFields('경도', longController),
      ],
    );
  }

  Widget _buildCoordinateFields(
      String label, TextEditingController controller) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        if (idController.text.trim().isEmpty ||
            nameController.text.trim().isEmpty ||
            passwordController.text.trim().isEmpty ||
            latController.text.trim().isEmpty ||
            longController.text.trim().isEmpty ||
            stimeController.text.trim().isEmpty ||
            etimeController.text.trim().isEmpty ||
            introController.text.trim().isEmpty ||
            addressController.text.trim().isEmpty ||
            telController.text.trim().isEmpty ||
            clinicHandler.imageFile == null) {
          errorDialogClinicAdd();
        } else {
          clincAdd();
        }
      },
      child: const Text(
        '추가하기',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Function

  updateClinicAddressData(String address, double lat, double long) {
    addressController.text = address.toString();
    latController.text = lat.toString();
    longController.text = long.toString();
  }

  errorDialogClinicAdd() async {
    await Get.defaultDialog(
      title: 'error',
      content: const Text('빈칸이 있는지 확인해주세요'),
      textCancel: '확인',
      barrierDismissible: true,
    );
  }

  clincAdd() async {
    await clinicHandler.uploadImage();
    clinicHandler.getClinicInsert(
      idController.text,
      nameController.text,
      passwordController.text,
      double.parse(latController.text),
      double.parse(longController.text),
      stimeController.text,
      etimeController.text,
      introController.text,
      addressController.text,
      telController.text,
      clinicHandler.filename,
    );
  }
}

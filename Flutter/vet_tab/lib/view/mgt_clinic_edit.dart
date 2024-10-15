import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vet_tab/view/mgt_clinic_map.dart';
import 'package:vet_tab/vm/clinic_handler.dart';

class MgtClinicEdit extends StatelessWidget {
  MgtClinicEdit({super.key});

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
  var value = Get.arguments ?? "__"; // clinicid = value
  clinicEditInitialInsert(value[0]);
    
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '병원 추가',
            style: TextStyle(fontSize: 30),
          ),
          leading: IconButton(
              onPressed: () {
                clinicHandler.imageFile = null;
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_ios)),
        ),
        body: GetBuilder<ClinicHandler>(
          builder: (_) {
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Container(
                                width: 400,
                                height: 300,
                                color: Colors.grey,
                                child: Center(
                                  child: clinicHandler.imageFile == null
                                      ? 
                                      Image.network(
                                      "http://127.0.0.1:8000/clinic/view/${clinicHandler.clinicDetail[0].image}")

                                      : Image.file(
                                    File(clinicHandler.imageFile!.path)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    clinicHandler.getImageFromGalleryEdit(
                                        ImageSource.gallery);
                                  },
                                  child: const Text('이미지 가져오기')),
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
                                  child: SizedBox(
                                      width: 100,
                                      child: Text(
                                        '영업시간 : ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 50, 0, 20),
                                  child: SizedBox(
                                    width: 100,
                                    child: Obx(() {
                                      // stimeController.text = clinicHandler.startOpTime.value;
                                      return TextField(
                                        onTap: () async {
                                          await clinicHandler.opDateSelection(
                                              context, true);
                                        },
                                        readOnly: true,
                                        controller: stimeController..text = clinicHandler.startOpTime.value,
                                        decoration: const InputDecoration(
                                            labelText: '영업시작'),
                                      );
                                    }),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
                                  child: Text(
                                    '~',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 50, 0, 20),
                                  child: SizedBox(
                                      width: 100,
                                      child: Obx(() {
                                        etimeController.text =
                                            clinicHandler.endOpTime.value;
                                        return TextField(
                                          onTap: () async {
                                            await clinicHandler.opDateSelection(
                                                context, false);
                                          },
                                          readOnly: true,
                                          controller: etimeController
                                            ..text =
                                                clinicHandler.endOpTime.value,
                                          decoration: const InputDecoration(
                                              labelText: '영업종료'),
                                        );
                                      })),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(100, 50, 0, 20),
                                  child: SizedBox(
                                      width: 100,
                                      child: Text(
                                        '아이디 : ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 50, 0, 20),
                                  child: SizedBox(
                                    width: 400,
                                    child: TextField(
                                      readOnly: true,
                                      controller: idController,
                                      decoration: const InputDecoration(
                                          labelText: '아이디를 입력해주세요'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(100, 0, 0, 20),
                                  child: SizedBox(
                                      width: 100,
                                      child: Text('비밀번호 : ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold))),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 20),
                                  child: SizedBox(
                                    width: 400,
                                    child: TextField(
                                      readOnly: true,
                                      controller: passwordController,
                                      decoration: InputDecoration(
                                        labelText: '비밀번호를 입력해주세요',
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              passwordController.clear();
                                              passwordController.text =
                                                  clinicHandler
                                                      .randomPasswordNumberClinic();
                                            },
                                            icon:
                                                const Icon(Icons.add_outlined)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(100, 0, 0, 20),
                                  child: SizedBox(
                                      width: 100,
                                      child: Text('병원이름 : ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold))),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 20),
                                  child: SizedBox(
                                    width: 400,
                                    child: TextField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                          labelText: '병원이름을 입력해주세요'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(100, 0, 0, 20),
                                  child: SizedBox(
                                      width: 100,
                                      child: Text('전화번호 : ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold))),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 20),
                                  child: SizedBox(
                                    width: 400,
                                    child: TextField(
                                      controller: telController,
                                      decoration: const InputDecoration(
                                          labelText: '전화번호를 입력해주세요'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(100, 0, 0, 20),
                                  child: SizedBox(
                                      width: 100,
                                      child: Text('주소 : ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold))),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: SizedBox(
                                    width: 400,
                                    child: TextField(
                                      controller: addressController,
                                      decoration: InputDecoration(
                                        labelText: '주소를 입력해주세요',
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              clinicHandler.updateAddress(
                                                  addressController.text);
                                              Get.to(() => MgtClinicMap(),
                                                      arguments:
                                                          addressController.text
                                                                  .trim()
                                                                  .isNotEmpty
                                                              ? addressController
                                                                  .text
                                                              : " ")
                                                  ?.then(
                                                (value) {
                                                  if (value != null) {
                                                    updateClinicAddressData(
                                                        value['address'],
                                                        value['lat'],
                                                        value['long']);
                                                  }
                                                },
                                              );
                                            },
                                            icon: const Icon(Icons.search)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(220, 0, 0, 0),
                                  child: Text('위도 : '),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 50, 0),
                                  child: SizedBox(
                                    width: 130,
                                    child: TextField(
                                      style: const TextStyle(fontSize: 15),
                                      readOnly: true,
                                      controller: latController,
                                      decoration: const InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Text('경도 : '),
                                SizedBox(
                                  width: 130,
                                  child: TextField(
                                    style: const TextStyle(fontSize: 15),
                                    readOnly: true,
                                    controller: longController,
                                    decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(100, 0, 0, 0),
                                  child: SizedBox(
                                      width: 100,
                                      child: Text('설명 : ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold))),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: SizedBox(
                                    width: 400,
                                    child: SizedBox(
                                      height: 200,
                                      child: TextField(
                                        maxLength: 150,
                                        expands: true,
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis),
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        controller: introController,
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        decoration: const InputDecoration(
                                          hintText: '설명을 입력하세요',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: SizedBox(
                        width: 170,
                        height: 70,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
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
                                  clinicHandler.imageFile == null ) {
                                errorDialogClinicAdd();
                              } else {
                                if (clinicHandler.firstDisp == 0) {
                                  clinicEdit();
                                } else {
                                  clinicEditAll();
                                }
                              }
                            },
                            child: const Text(
                              '추가하기',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  //Function
  updateClinicAddressData(String address,double lat,double long){
    addressController.text = address.toString();
    latController.text = lat.toString();
    longController.text = long.toString();
  }

    // errorDialog when any of the textfield from the page are empty (안창빈)
  errorDialogClinicAdd() async {
    await Get.defaultDialog(
      title: 'error',
      content: const Text('빈칸이 있는지 확인해주세요'),
      textCancel: '확인',
      barrierDismissible: true,
    );
  }

  //add clinic information (안창빈)
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
  //edit clinic information (안창빈)
clinicEdit()async{
    await clinicHandler.getClinicUpdate(
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
    );
}
  //add clinic information include image (안창빈)
clinicEditAll() async{
    await clinicHandler.deleteClinicImage(clinicHandler.clinicDetail[0].image);
    await clinicHandler.uploadImage();
    await clinicHandler.getClinicUpdateAll(
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

  /// input initial value to the clinic edit page
  clinicEditInitialInsert(String id)async{
    final result = clinicHandler.clinicDetail;

      idController.text = result[0].id; 
      nameController.text = result[0].name;
      passwordController.text = result[0].password; 
      latController.text = result[0].latitude.toString();
      longController.text = result[0].longitude.toString(); 
      introController.text = result[0].introduction; 
      addressController.text = result[0].address; 
      telController.text = result[0].phone; 
      clinicHandler.updateInitialClinicTimeEdit(result[0].startTime, result[0].endTime);
      print(result[0].image);
  }
}//END

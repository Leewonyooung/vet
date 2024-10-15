import 'package:vet_tab/vm/login_handler.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SpeciesHandler extends LoginHandler {
  TextEditingController speciesController = TextEditingController();
  var categoryList = [].obs;

  categoryInsert(String category) async {
    var url = Uri.parse(
        "http://127.0.0.1:8000/species/add?species_category=$category");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var results = dataConvertedJSON['results'];
    if (results == 'OK'){
      speciesController.clear();
      clinicInsertCompleteDialog();
    }else{
      speciesInsertEditErrorDialog();
    }
      return results;
  }

  // error dialog insert clinic (안창빈)

  speciesInsertEditErrorDialog()async{
      await Get.defaultDialog(
      title: '에러',
      content: const Text('이미 있는 견종입니다'),
      textConfirm: '확인',
      onConfirm: () {
        Get.back();
      },
      barrierDismissible: true,
    );
  }

  // complete dialog insert clinic (안창빈)

  clinicInsertCompleteDialog()async{
      await Get.defaultDialog(
      title: '확인',
      content: const Text('견종이 추가되었습니다'),
      textConfirm: '확인',
      onConfirm: () {
        Get.back();
        Get.back();
      },
      barrierDismissible: true,
    );
  }

  speciesInsertDialog()async{
      await Get.defaultDialog(
        radius: 10,
      title: '견종 추가',
      content: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: 300,
                child: TextField(
                    controller: speciesController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '견종을 입력하세요',
                      suffixIcon: IconButton(
                        onPressed:() {
                        categoryInsert(speciesController.text);
                        },
                        icon: Icon(Icons.add),
                      ),
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }



}

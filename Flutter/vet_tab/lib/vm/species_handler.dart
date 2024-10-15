import 'package:vet_tab/model/speciessearch.dart';
import 'package:vet_tab/vm/login_handler.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SpeciesHandler extends LoginHandler {
  TextEditingController speciesController = TextEditingController();
  var categoryList = [].obs;
  var selectedItem = 0.obs;

  categoryquery() async {
    var url = Uri.parse(
        "http://127.0.0.1:8000/species/categories");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var results = dataConvertedJSON['results'];
    List <Speciessearch> returnData = [];

        for (int i = 0; i < results.length; i++) {
      String  categoryinsert= results[i];
      returnData.add(Speciessearch(category: categoryinsert ));}
    categoryList.value = returnData;
  }


  categoryInsert(String category) async {
    var url = Uri.parse(
        "http://127.0.0.1:8000/species/add?species_category=$category");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var results = dataConvertedJSON['results'];
    if (results == 'OK'){
      clinicInsertCompleteDialog();
    }else{
      clinicInsertEditErrorDialog();
    }
      return results;
  }

  // error dialog insert clinic (안창빈)

  clinicInsertEditErrorDialog()async{
      await Get.defaultDialog(
      title: '에러',
      content: const Text('예기치 못한 오류가 발생했습니다.'),
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
      content: const Text('병원 정보가 추가되었습니다'),
      textConfirm: '확인',
      onConfirm: () {
        Get.back();
      },
      barrierDismissible: true,
    );
  }


  void updateSelectedItem(int index) {
    selectedItem.value = index;
  }




}

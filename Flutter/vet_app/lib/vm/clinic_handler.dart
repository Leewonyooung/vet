import 'dart:convert';

import 'package:get/get.dart';
import 'package:vet_app/model/clinic.dart';
import 'package:vet_app/vm/time_handler.dart';
import 'package:http/http.dart' as http;

class ClinicHandler extends TimeHandler{
  String searchkeyward ="";
  var search = <Clinic>[].obs;
  var detail = <Clinic>[].obs;


    // 병원 전체 목록
    getAllClinic()async{
    var url = Uri.parse('http://127.0.0.1:8000/clinic/select_clinic');
    var response = await http.get(url);
    search.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    List <Clinic> returnData = [];
    

        for (int i = 0; i < results.length; i++) {
      String id= results[i][0];
      String  name= results[i][1];
      String password = results[i][2];
      double latitude = results[i][3];
      double longitude = results[i][4];
      String  startTime= results[i][5];
      String endTime = results[i][6];
      String? introduction = results[i][7] ?? '소개 없음';
      String? address = results[i][8]  ?? '주소 없음';
      String? phone = results[i][9] ?? '전화번호 없음';
      String image = results[i][10];


      returnData.add(Clinic(id: id,name: name, password: password, latitude: latitude, longitude: longitude, startTime: startTime, endTime: endTime, introduction: introduction!, address: address!, phone: phone!,image: image));}
    search.value = returnData;
  }

//  // 병원 상세 정보
      getClinicDetail(String clinicid)async{
    var url = Uri.parse('http://127.0.0.1:8000/clinic/detail_clinic?id=$clinicid');
    var response = await http.get(url);
    detail.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    List <Clinic> returnData = [];
    

      String id= results[0][0];
      String name = results[0][1];
      String password = results[0][2];
      double latitude = results[0][3];
      double longitude = results[0][4];
      String startTime = results[0][5];
      String endTime = results[0][6];
      String? introduction = results[0][7];
      String? address = results[0][8];
      String? phone = results[0][9];
      String image = results[0][10];


      returnData.add(Clinic(id: id,name: name, password: password, latitude: latitude, longitude: longitude, startTime: startTime, endTime: endTime, introduction: introduction!, address: address!, phone: phone!, image: image));
    detail.value = returnData;
      }
  }




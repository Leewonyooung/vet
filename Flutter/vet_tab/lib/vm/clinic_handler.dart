import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vet_tab/model/clinic.dart';
import 'package:vet_tab/vm/login_handler.dart';

class ClinicHandler extends LoginHandler{
  String searchkeyward ="";
  var clinicSearch = <Clinic>[].obs;
  var clinicDetail = <Clinic>[].obs;
  String startOpTime = '';
  String endOpTime = '';
  DateTime selectedDate = DateTime.now();

    getUserId() async {
    // api를 통해 userID가져옴
    await box.write('userId', '1234');
  }

  RxString currentIndex = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    await getAllClinic();
    await checkLocationPermission();
  }
  updateCurrentIndex(String str){
    currentIndex.value = str;
    update();
  }
    // 병원 전체 목록
    getAllClinic()async{
    var url = Uri.parse('http://127.0.0.1:8000/clinic/select_clinic');
    var response = await http.get(url);
    clinicSearch.clear();
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
      String? image = results[i][10] ?? '이미지 없음';


      returnData.add(Clinic(id: id,name: name, password: password, latitude: latitude, longitude: longitude, startTime: startTime, endTime: endTime, introduction: introduction!, address: address!, phone: phone!, image: image!));}
    clinicSearch.value = returnData;
  }

//  // 병원 상세 정보
  getClinicDetail(String clinicid)async{
    var url = Uri.parse('http://127.0.0.1:8000/clinic/detail_clinic?id=$clinicid');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'][0];
    List <Clinic> returnData = [];
    

      String id= results[0];
      String name = results[1];
      String password = results[2];
      double latitude = results[3];
      double longitude = results[4];
      String startTime = results[5];
      String endTime = results[6];
      String? introduction = results[7];
      String? address = results[8];
      String? phone = results[9];
      String? image = results[10];
      returnData.add(Clinic(id: id,name: name, password: password, latitude: latitude, longitude: longitude, startTime: startTime, endTime: endTime, introduction: introduction!, address: address!, phone: phone!, image: image!));
      clinicDetail.value = returnData;
    }

  // insert clinic (안창빈)

  getClinicInsert(
      String id,
      String name,
      String password,
      double latitude,
      double longitude,
      String stime,
      String etime,
      String introduction,
      String address,
      String phone,
      String image) async {
    var url = Uri.parse(
        "http://127.0.0.1:8000/clinic/insert?id=$id&name=$name&password=$password&latitude=$latitude&longitude=$longitude&stime=$stime&etime=$etime&introduction=$introduction&address=$address&phone=$phone&image=$image");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var results = dataConvertedJSON['results'];
    return results;
  }

  // update clinic (안창빈)

  getClinicUpdate() async {
    var url = Uri.parse("http://127.0.0.1:8000/clinic/update?");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var results = dataConvertedJSON['results'];
    return results;
  }

  // insert clinic (안창빈)

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }

  opDateSelection(bool isStartDate) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 300,
            child: CupertinoDatePicker(
              maximumYear: 2030,
              minimumYear: 2020,
              initialDateTime: DateTime.now(),
              mode: CupertinoDatePickerMode.time,
              onDateTimeChanged: (DateTime date) {
                  selectedDate = date;
                  if (isStartDate) {
                    startOpTime = formatDate(date);
                  } else {
                    endOpTime = formatDate(date);
                  }
              },
            ),
          ),
        );
      },
      barrierDismissible: true,
    );
  }

}
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:vet_tab/model/clinic.dart';
import 'package:vet_tab/vm/image_handler.dart';
import 'package:vet_tab/vm/login_handler.dart';

class ClinicHandler extends LoginHandler{
  ImageHandler imageHandler = ImageHandler();
  String searchkeyward ="";
  var clinicSearch = <Clinic>[].obs;
  var clinicDetail = <Clinic>[].obs;
  var startOpTime = ''.obs;
  var endOpTime = ''.obs;
  DateTime selectedDate = DateTime.now();
  RxString selected = ''.obs;
  

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
        "http://127.0.0.1:8000/clinic/insert?id=$id&name=$name&password=$password&latitude=$latitude&longitude=$longitude&starttime=$stime&endtime=$etime&introduction=$introduction&address=$address&phone=$phone&image=$image");
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

  // errorDialog when any of the textfield from the page are empty (안창빈)
  errorDialogClinicAdd() async {
    await Get.defaultDialog(
      title: 'error',
      content: const Text('빈칸이 있는지 확인해주세요'),
      textCancel: '확인',
      barrierDismissible: true,
    );
  }

  // update clinic except image (안창빈)

  getClinicUpdate(
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
  ) async {
    var url = Uri.parse("http://127.0.0.1:8000/clinic/update?id=$id&name=$name&password=$password&latitude=$latitude&longitude=$longitude&starttime=$stime&endtime=$etime&introduction=$introduction&address=$address&phone=$phone");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var results = dataConvertedJSON['results'];
    if (results == 'OK'){
      clinicEditCompleteDialog();
    }else{
      clinicInsertEditErrorDialog();
    }
    return results;
    
  }

  // update clinic include image (안창빈)

  getClinicUpdateAll(
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
      String image
  ) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/clinic/update_all?id=$id&name=$name&password=$password&latitude=$latitude&longitude=$longitude&starttime=$stime&endtime=$etime&introduction=$introduction&address=$address&phone=$phone&image=$image');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 'OK'){
      clinicEditCompleteDialog();
    }else{
      clinicInsertEditErrorDialog();
    }
    return result;
    
  }

    // complete dialog insert clinic (안창빈)

  clinicEditCompleteDialog()async{
      await Get.defaultDialog(
      title: '확인',
      content: const Text('병원 정보가 변경되었습니다'),
      textConfirm: '확인',
      onConfirm: () {
        Get.back();
      },
      barrierDismissible: true,
    );
  }


  // Format date to '오전 7:30' style in Korean
  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('a h:mm', 'ko');
    final formattedDate = formatter.format(date);
    return formattedDate;
  }

  // Initialize locale to Korean (안창빈)
  initializeLocale() async {
    await initializeDateFormatting('ko', null); 
  }

  // Date picker for clinic edit and add page (안창빈) 

  opDateSelection(BuildContext context, bool isStartDate)  {
    initializeLocale();
    DateTime tempDate = selectedDate;
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 300,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: CupertinoDatePicker(
                    backgroundColor: Colors.white,
                    maximumYear: 2030,
                    minimumYear: 2020,
                    initialDateTime: selectedDate, 
                    mode: CupertinoDatePickerMode.time,
                    onDateTimeChanged: (DateTime date) {
                      tempDate = date;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    selectedDate = tempDate; 
                    if (isStartDate) {
                      startOpTime.value = formatDate(selectedDate);
                    } else if (!isStartDate){
                      endOpTime.value = formatDate(selectedDate);
                    }
                    update();
                    Get.back(); 
                  },
                  child: const Text('시간선택'),
                ),
              ],
            ),
          ),
        );
      },
      barrierDismissible: true,
    );
  }

  // update initial time setting while entering clinic edit page(안창빈)
  updateInitialClinicTimeEdit(String starttime,String endtime){
    startOpTime.value = starttime;
    endOpTime.value = endtime;
  }



}
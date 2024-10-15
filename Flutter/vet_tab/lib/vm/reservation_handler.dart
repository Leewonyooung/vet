import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vet_tab/model/available_clinic.dart';
import 'package:vet_tab/model/current_situation_clinic.dart';
import 'package:vet_tab/model/reservation.dart';
import 'package:vet_tab/vm/clinic_handler.dart';
import 'package:vet_tab/vm/login_handler.dart';

class ReservationHandler extends ClinicHandler {
  final reservations = <Reservation>[].obs;
  final availableclinic = <AvailableClinic>[].obs;
  String reservationTime = "";
  final clinicreservations = <CurrentSituationClinic>[].obs;
  String resuserid = "";
  LoginHandler loginHandler = Get.find();


  // 예약된 리스트
  getReservation() async {
    var url = Uri.parse('http://127.0.0.1:8000/'); //미완성
    var response = await http.get(url);
    clinicSearch.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    // ignore: unused_local_variable
    List results = dataConvertedJSON['results'];
    // ignore: unused_local_variable
    List<Reservation> returnData = [];
  }

  // 메인화면에서 긴급예약 눌렀을때 보여주는 리스트
  getQuickReservation() async {
    await adjustedTime();
    var url = Uri.parse(
        'http://127.0.0.1:8000/available/available_clinic?time=$reservationTime'); // 미완성
    var response = await http.get(url);
    clinicSearch.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    List<AvailableClinic> returnData = [];

    for (int i = 0; i < results.length; i++) {
      String name = results[i][0];
      double latitude = results[i][1];
      double longitude = results[i][2];
      String address = results[i][3];
      String image = results[i][4];
      String time = results[i][5];

      returnData.add(AvailableClinic(
          name: name,
          latitude: latitude,
          longitude: longitude,
          address: address,
          image: image,
          time: time));
      availableclinic.value = returnData;
    }
  }

  // 현재시간 기점으로 가까운 예약시간으로 변경해주는 함수
  adjustedTime() {
    DateTime adjustedTime = adjustToNearestHalfHour(DateTime.now());
    reservationTime =
        "${adjustedTime.year.toString().substring(2, 4)}.${adjustedTime.month.toString().padLeft(2, '0')}.${adjustedTime.day.toString().padLeft(2, '0')}.${adjustedTime.hour.toString().padLeft(2, '0')}:${adjustedTime.minute.toString().padLeft(2, '0')}";
  }

  DateTime adjustToNearestHalfHour(DateTime currentTime) {
    int hour = currentTime.hour;
    int minute = currentTime.minute;

    if (minute < 30) {
      minute = 30;
    } else {
      minute = 0;
      hour += 1;
    }
    return DateTime(
        currentTime.year, currentTime.month, currentTime.day, hour, minute);
  }

  // 병원 예약 현황
  currentReservationClinic() async {
    await storeuser();
    await adjustedTime();
    var url = Uri.parse(
        'http://127.0.0.1:8000/reservation/select_reservation_clinic?clinic_id=$resuserid&time=${reservationTime.substring(0,8)}');
    var response = await http.get(url);
    clinicSearch.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    List<CurrentSituationClinic> returnData = [];
    returnData.add(CurrentSituationClinic(userName: '예약자', petType: '종류', petCategory: '품종', petFeatures: '특징', symptoms: '증상', time: '예약시간'));
    for (int i = 0; i < results.length; i++) {
      String userName = results[i][0];
      String petType = results[i][1];
      String petCategory = results[i][2];
      String petFeatures = results[i][3];
      String symptoms = results[i][4];
      String time = results[i][5];

      returnData.add(CurrentSituationClinic(
          userName: userName,
          petType: petType,
          petCategory: petCategory,
          petFeatures: petFeatures,
          symptoms: symptoms,
          time: time));
      clinicreservations.value = returnData;
    }
  }

  storeuser(){
    resuserid = loginHandler.box.read('id') ?? 'cmzmnvj274';
    update();
  }

}

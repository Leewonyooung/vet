import 'dart:convert';
import 'package:get/state_manager.dart';
import 'package:vet_app/model/available_clinic.dart';
import 'package:vet_app/model/reservation.dart';
import 'package:vet_app/vm/clinic_handler.dart';
import 'package:http/http.dart' as http;

class ReservationHandler extends ClinicHandler {
  final reservations = <Reservation>[].obs;
  final availableclinic = <AvailableClinic>[].obs;
  String reservationTime = "";
  final canReservationClinic =
      <AvailableClinic>[].obs; //정섭 = 병원 상세정보에서 예약으로 데이터 넘기기 위한 리스트
  var resButtonValue = false.obs;
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

  // make_reservation에서 사용할 예약 insert
  makeReservation(
      String userId, String clinicId, String time, String symptoms) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/reservation/insert_reservation?user_id=$userId&clinic_id=$clinicId&time=$time&symptoms=$symptoms');
    var response = await http.get(url);

    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var results = dataCovertedJSON['results'];
    List<Reservation> returnData = [];

    for (int i = 0; i < results.length; i++) {
      String userId = results[i][0];
      String clinicId = results[i][0];
      String time = results[i][0];
      String symptoms = results[i][0];

      returnData.add(Reservation(
          userId: userId, clinicId: clinicId, time: time, symptoms: symptoms));
      reservations.value = returnData;
    }
    return results;
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
      String id = results[i][0];
      String name = results[i][1];
      double latitude = results[i][2];
      double longitude = results[i][3];
      String address = results[i][4];
      String image = results[i][5];
      String time = results[i][6];

      returnData.add(AvailableClinic(
          id: id,
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

  // clinic_info -> 예약버튼 활성화 관리
  reservationButtonMgt(String clinicid) async {
    await adjustedTime();
    canReservationClinic.clear();
    var url = Uri.parse(
        'http://127.0.0.1:8000/available/can_reservation?time=$reservationTime&clinic_id=$clinicid');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    List<AvailableClinic> returnData = [];
    if (result != null) {
      resButtonValue.value = true;
      String id = result[6];
      String name = result[0];
      double latitude = result[1];
      double longitude = result[2];
      String address = result[3];
      String image = result[4];
      String time = result[5];
      returnData.add(AvailableClinic(
          id: id,
          name: name,
          latitude: latitude,
          longitude: longitude,
          address: address,
          image: image,
          time: time));
      canReservationClinic.value = returnData;
    } else {
      resButtonValue.value = false;
    }
  }
}

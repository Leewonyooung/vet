import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vet_app/vm/clinic_handler.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/clinic.dart';
import 'package:http/http.dart' as http;
import 'package:vet_app/vm/login_handler.dart';
class FavoriteHandler extends ClinicHandler {
  var favoriteClinics = <Clinic>[].obs; // 즐겨찾기 병원 목록
  IconButton favoriteButtonIcon = IconButton(onPressed: () {},icon: const Icon(Icons.favorite_outline));
  final LoginHandler loginHandler = Get.find();

  @override
  void onInit() async {
    super.onInit();
    await getFavoriteClinics(loginHandler.getStoredEmail());
  }

  // 즐겨찾기 목록 불러오기
  Future<void> getFavoriteClinics(String userId) async {
    try {
      var url = Uri.parse(
          'http://127.0.0.1:8000/favorite/favorite_clinics?user_id=$userId'); // 사용자 ID 기반 즐겨찾기 요청
      var response = await http.get(url);

      // 응답 상태가 성공적인지 확인
      if (response.statusCode == 200) {
        var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));

        // results 필드가 존재하는지 확인
        if (dataConvertedJSON['results'] != null) {
          List results = dataConvertedJSON['results'];
          List<Clinic> returnData = [];

          // JSON 데이터를 Clinic 객체 리스트로 변환
          for (int i = 0; i < results.length; i++) {
            String id = results[i][2]; // clinic_id
            String name = results[i][3]; // 병원 이름
            String password = results[i][4];
            double latitude = results[i][5];
            double longitude = results[i][6];
            String startTime = results[i][7];
            String endTime = results[i][8];
            String? introduction = results[i][9] ?? '소개 없음';
            String? address = results[i][10] ?? '주소 없음';
            String? phone = results[i][11] ?? '전화번호 없음';
            String? image = results[i][12] ?? '이미지 없음';

            returnData.add(Clinic(
                id: id,
                name: name,
                password: password,
                latitude: latitude,
                longitude: longitude,
                startTime: startTime,
                endTime: endTime,
                introduction: introduction!,
                address: address!,
                phone: phone!,
                image: image!));
          }

          // 즐겨찾기 병원 목록 업데이트 (assignAll 사용)
          favoriteClinics.value = returnData;
          // update(); // 상태 업데이트
        } else {
          // results가 없는 경우 처리
          throw Exception('results 필드가 응답에 존재하지 않습니다.');
        }
      } else {
        // 응답 상태가 성공적이지 않은 경우
        throw Exception('데이터를 불러오는 데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      // 필요 시 에러 메시지를 UI에 전달
    }
  }

  // 즐겨찾기 병원 추가
  addFavoriteClinic(String userId, String clinicId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/favorite/add_favorite?user_id=$userId&clinic_id=$clinicId');
    var response = await http.post(url);
    if (response.statusCode == 200) {
      return "OK";
    } else {
      return;
    }
  }

// 즐겨찾기 병원 삭제
  Future<void> removeFavoriteClinic(String userId, String clinicId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/favorite/delete_favorite?user_id=$userId&clinic_id=$clinicId');
    var response = await http.delete(url);

    if (response.statusCode == 200) {
      // 마지막 데이터 삭제 후 리스트 비우기
      favoriteClinics.removeWhere((clinic) => clinic.id == clinicId);

      // 만약 리스트가 비어있으면 명시적으로 리스트를 비움
      if (favoriteClinics.isEmpty) {
        favoriteClinics.clear(); // 빈 리스트 명시적으로 비우기
      }

      update(); // 상태 업데이트
    }
  }

  searchFavoriteClinic(String userId, String clinicId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/favorite/search_favorite_clinic?user_id=$userId&clinic_id=$clinicId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    int result = dataConvertedJSON['results'];
    if (result == 1) {
      favoriteButtonIcon = IconButton(
        onPressed: () => removeFavoriteClinic(userId, clinicId),
        icon: const Icon(Icons.favorite, color: Colors.red),
      );
    } else {
      favoriteButtonIcon = IconButton(
          onPressed: () => addFavoriteClinic(userId, clinicId),
          icon: const Icon(
            Icons.favorite_outline,
          ));
    }
  }
}

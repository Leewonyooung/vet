import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vet_app/model/userdata.dart';
import 'package:vet_app/vm/location_handler.dart';
import 'package:http/http.dart' as http;

class UserHandler extends LocationHandler {
  final box = GetStorage();
  var mypageUserInfo = <UserData>[].obs; // mypage 화면 데이터
  String nameController = ""; // 유저 이름 수정 텍스트필드

// 신정섭
// 유저 정보 가져오는 쿼리 - mypage
  selectMyinfo(String userid) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/mypage/select_mypage?id=$userid');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    List<UserData> returnData = [];
    if (result != null) {
      mypageUserInfo.clear();
      String? id = result[0];
      String password = result[1];
      String image = result[2];
      String name = result[3];
      returnData
          .add(UserData(password: password, image: image, name: name, id: id));
      mypageUserInfo.value = returnData;
    }
  }

  // user name update - mypage update
  updateUserName(String name, String id) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/mypage/name_update?name=$name&id=$id');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    return result;
  }

// user name image update - mypage update
// update 순서  - 업로드된 이미지 파일 삭제 => 신규 이미지 업로드 => update
  updateUserAll(String name, String image, String id) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/mypage/all_update?name=$name&image=$image&id=$id');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    return result;
  }
}

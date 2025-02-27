import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vet_app/model/userdata.dart';
import 'package:vet_app/vm/myapi.dart';

class UserHandler extends Myapi {
  final box = GetStorage();
  var mypageUserInfo = <UserData>[].obs; // mypage 화면 데이터
  String nameController = ""; // 유저 이름 수정 텍스트필드

  @override
  void onInit() async {
    super.onInit();
    await selectMyinfo();
  }
getMyName(String userid) async {
    var response = await makeAuthenticatedRequest('$server/mypage/select_mypage?id=$userid');
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    return result[3];
  }

// 신정섭
// 유저 정보 가져오는 쿼리 - mypage
selectMyinfo( ) async {
    if(box.read('userEmail') == null) return;
    try {
      final response = await makeAuthenticatedRequest('$server/user/selectuser?id=${box.read('userEmail')}');
        if (response.statusCode == 200) {
          var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
          var result = dataConvertedJSON['results'][0];
          if (result != null) {
            mypageUserInfo.clear();
            String id = result['id'];
            String password = result['password'];
            String image = result['image'];
            String name = result['name'];

            List<UserData> returnData = [];
            returnData.add(UserData(
              id: id,
              password: password,
              image: image,
              name: name,
            ));
            mypageUserInfo.addAll(returnData);
        }}
        }catch (e) {
          return;
        }

  }


  // user name update - mypage update
  updateUserName(String name, String id) async {
    var response = await makeAuthenticatedRequest('$server/mypage/name_update?name=$name&id=$id');
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    return result;
  }

// user name image update - mypage update
// update 순서  - 업로드된 이미지 파일 삭제 => 신규 이미지 업로드 => update
  updateUserAll(String name, String image, String id) async {
    var response = await makeAuthenticatedRequest('$server/mypage/all_update?name=$name&image=$image&id=$id');
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    return result;
  }
}

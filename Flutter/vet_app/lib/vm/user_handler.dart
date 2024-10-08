import 'dart:convert';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vet_app/model/userdata.dart';
import 'package:vet_app/vm/time_handler.dart';
import 'package:http/http.dart' as http;

class UserHandler extends TimeHandler {
  var mypageUserInfo = <UserData>[].obs;
  String nameController = ""; // 유저 이름 수정 텍스트필드
  XFile? userImageFile;
  final ImagePicker userImagePicker = ImagePicker();
  int userImageValue = 0;

  getUserId() async {
    // api를 통해 userID가져옴
    await box.write('userId', 'test');
  }

  selectMyinfo() async {
    await getUserId();
    var url = Uri.parse(
        'http://127.0.0.1:8000/mypage/select_mypage?id=${box.read('userId')}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'][0];
    mypageUserInfo.clear();
    String? id = result[0];
    String password = result[1];
    String image = result[2];
    String name = result[3];
    mypageUserInfo
        .add(UserData(password: password, image: image, name: name, id: id));
    update();
  }

  getImageFromDevice(imageSource) async {
    final XFile? pickedFile =
        await userImagePicker.pickImage(source: imageSource); //image 불러오기
    if (pickedFile != null) {
      userImageFile = XFile(pickedFile.path);
      userImageValue++;
      update();
    }
  }
}

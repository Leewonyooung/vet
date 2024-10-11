import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vet_app/model/userdata.dart';
import 'package:vet_app/vm/location_handler.dart';
import 'package:http/http.dart' as http;

class UserHandler extends LocationHandler {
  final box = GetStorage();
  var mypageUserInfo = <UserData>[].obs;
  String nameController = ""; // 유저 이름 수정 텍스트필드
  XFile? userImageFile;
  final ImagePicker userImagePicker = ImagePicker();
  int userImageValue = 0;

  getUserId() async {
    // api를 통해 userID가져옴
    await box.read('userEmail');
  }

  selectMyinfo(String userid) async {
    await getUserId();
    var url = Uri.parse(
        'http://127.0.0.1:8000/mypage/select_mypage?id=$userid');
    var response = await http.get(url);
    if (response.statusCode == 200) {
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

    // user name update
  updateUserName(String name, String id)async{
  var url = Uri.parse('http://127.0.0.1:8000/mypage/name_update?name=$name&id=$id');
  await http.get(url);
  update();
}

  updateJSONDataAll() async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/mypage/all_update?=');
    await http.get(url);
    update();
  }
}

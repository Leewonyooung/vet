import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageHandler extends GetxController {
  XFile? imageFile;
  late int firstDisp = 0;
  final ImagePicker picker = ImagePicker();
  String filename = ""; // 선택한 파일 이름

  getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    imageFile = XFile(pickedFile!.path);
    update();
  }

  // 신정섭
  // mypage update - 갤러리에서 유저 이미지 선택하기
  getImageFromGalleryEdit(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      // 이미지가 선택될 경우에만 firstdisp update
      imageFile = XFile(pickedFile.path);
      firstDisp++;
      update();
    }
  }

//이미지 업로드
  uploadUserImage() async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/mypage/upload_userimage'));
    var multipartfile =
        await http.MultipartFile.fromPath('file', imageFile!.path);
    request.files.add(multipartfile);
    List preFileName = imageFile!.path.split('/');
    filename = preFileName[preFileName.length - 1]; // filename을 쪼개서 마지막 이름만 선택
    var response = await request.send();
    if (response.statusCode == 200) {
      // print('ok');
    } else {
      // print('error');
    }
  }

  // 업로드된 이미지 삭제
  deleteUserImage(String userimage) async {
    if(userimage != 'usericon.jpg'){
    var url = Uri.parse('http://127.0.0.1:8000/mypage/deleteFile/$userimage');
    var response = await http.delete(url);
    if (response.statusCode == 200) {
      return 'ok';
    } else {
      // print('error');
    }
  }
  }
}

import 'package:image_picker/image_picker.dart';
import 'package:vet_tab/vm/tab_vm.dart';
import 'package:http/http.dart' as http;

class ImageHandler extends TabVm {

  XFile? imageFile;
  late int firstDisp = 0;
  final ImagePicker picker = ImagePicker();
  String filename = "";

  getImageFromGallery(ImageSource imageSource)async{
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null){
    imageFile = XFile(pickedFile!.path);
    update();
    }
  }

    uploadImage() async {
    var request = http.MultipartRequest( // 이미지를 잘라서 보내는 방식
      "POST", Uri.parse("http://127.0.0.1:8000/clinic/upload"));
    var multipartFile = 
      await http.MultipartFile.fromPath('file', imageFile!.path);
    request.files.add(multipartFile);

    // for get file name
    List preFilename = imageFile!.path.split('/');
    filename = preFilename[preFilename.length - 1];

    var response = await request.send();

    if(response.statusCode == 200){
      
    }else{
    }
  }

    Future getImageFromGalleryEdit(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      return;
    } else {
      imageFile = XFile(pickedFile.path);
      firstDisp++;
      update();
    }
}

  deleteClinicImage(String clinicImage) async {
    var url = Uri.parse('http://127.0.0.1:8000/clinic/deleteFile/$clinicImage');
    var response = await http.delete(url);
    if (response.statusCode == 200) {
      return 'ok';
    } else {
      // print('error');
    }
  }
}



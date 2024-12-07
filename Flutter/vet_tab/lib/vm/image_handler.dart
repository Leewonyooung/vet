import 'package:image_picker/image_picker.dart';
import 'package:vet_tab/vm/tab_vm.dart';
import 'package:http/http.dart' as http;

class ImageHandler extends TabVm {
  XFile? imageFile;
  late int firstDisp = 0;
  final ImagePicker picker = ImagePicker();
  String filename = "";
  
  //Get image from gallery from add page (안창빈)
  getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      imageFile = XFile(pickedFile.path);
      update();
    }
  }

  // upload image (안창빈)
  uploadImage() async {
    var request = http.MultipartRequest(
        "POST", Uri.parse("$server/clinic/upload"));
    var multipartFile =
        await http.MultipartFile.fromPath('file', imageFile!.path);
    request.files.add(multipartFile);

    List preFilename = imageFile!.path.split('/');
    filename = preFilename[preFilename.length - 1];

    var response = await request.send();

    if (response.statusCode == 200) {
    } else {}
  }

  //Get image from gallery from edit page (안창빈)
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

  //delete image before upload (안창빈)
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

import 'package:image_picker/image_picker.dart';
import 'package:vet_tab/vm/tab_vm.dart';

class ImageHandler extends TabVm {

  XFile? imageFile;
  late int firstDisp = 0;
  final ImagePicker picker = ImagePicker();

  getImageFromGallery(ImageSource imageSource)async{
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    imageFile = XFile(pickedFile!.path);
    update();
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
}
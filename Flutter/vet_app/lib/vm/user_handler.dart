import 'package:get_storage/get_storage.dart';
import 'package:vet_app/vm/time_handler.dart';


class UserHandler extends TimeHandler{
  final box = GetStorage();
  getUserId() async{
    // api를 통해 userID가져옴
    await box.write('userId', '1234');
  }
}
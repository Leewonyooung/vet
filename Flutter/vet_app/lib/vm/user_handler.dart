import 'package:vet_app/vm/time_handler.dart';


class UserHandler extends TimeHandler{
  getUserId() async{
    // api를 통해 userID가져옴
    await box.write('userId', '1234');
  }
}
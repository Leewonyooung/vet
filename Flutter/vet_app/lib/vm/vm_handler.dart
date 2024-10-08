import 'package:vet_app/vm/location_handler.dart';

class VmHandler extends LocationHandler{
  
  @override
  void onInit() async{
    super.onInit();
    await getAllClinic();
    await makeChatRoom();
    await queryLastChat();
    await getlastName();
  }
  
}
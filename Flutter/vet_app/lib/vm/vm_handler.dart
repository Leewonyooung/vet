import 'package:vet_app/vm/chat_handler.dart';

class VmHandler extends ChatsHandler{
  
  @override
  void onInit() {
    super.onInit();
    getUserId();
  }
  
}
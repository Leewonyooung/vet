import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/chatroom.dart';
import 'package:vet_app/model/chats.dart';
import 'package:vet_app/view/chat_view.dart';
import 'package:vet_app/vm/vm_handler.dart';

class ChatRoom extends StatelessWidget {
  ChatRoom({super.key});
  
  final VmHandler vmHandler = Get.find();
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('상담방'),
      ),
      body: Obx(() => chatRoomList(context),)
    );
  }

  chatRoomList(context){
    return SizedBox(
      height: MediaQuery.of(context).size.height/1.5,
      child: ListView.builder(
        itemCount: vmHandler.rooms.length,
        itemBuilder: (context, index) {
          Chatroom room = vmHandler.rooms[index];
          // vmHandler.queryLastChat();
          // Chats lastchat = vmHandler.lastChats[index];
          // print(lastchat.text);
          return GestureDetector(
            onTap: () async{
              vmHandler.currentClinicId.value = room.clinic;
              await vmHandler.queryChat();
              Get.to(() => ChatView(),);
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment:MainAxisAlignment.end,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.network(room.image, width: 70,),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              room.clinic,
                              style: const TextStyle(
                                fontSize: 22
                              ),
                            ),
                          ),
                          Text(vmHandler.lastChats[index].text)
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ),
          );
        },
      ),
    );
  }

  

}
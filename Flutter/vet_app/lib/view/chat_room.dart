import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/chatroom.dart';
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
        body: Obx(
          () => chatRoomList(context),
        ));
  }

  chatRoomList(context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.5,
      child: ListView.builder(
        itemCount: vmHandler.rooms.length,
        itemBuilder: (context, index) {
          Chatroom room = vmHandler.rooms[index];
          return GestureDetector(
            onTap: () async {
              vmHandler.currentClinicId.value = room.clinic;
              await vmHandler.queryChat();
              Get.to(
                () => ChatView(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  height: MediaQuery.of(context).size.height / 8.5,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.05,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15)),
                                  width: 70,
                                  height: 70,
                                  child: Image.network(
                                    room.image,
                                    fit: BoxFit.cover,
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      vmHandler.roomName[index],
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    Row(
                                      children: [
                                        Text(vmHandler.lastChats[index].text),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      width: MediaQuery.of(context).size.width /
                                          1.5,
                                      child: DateTime.now().difference(
                                                  DateTime.parse(vmHandler
                                                      .lastChats[index]
                                                      .timestamp)) <
                                              const Duration(hours: 24)
                                          ? Text(vmHandler
                                              .lastChats[index].timestamp
                                              .substring(11, 16))
                                          : Text(
                                              "${vmHandler.lastChats[index].timestamp.substring(5, 7)}월 ${vmHandler.lastChats[index].timestamp.substring(8, 10)}일"),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          );
        },
      ),
    );
  }
}

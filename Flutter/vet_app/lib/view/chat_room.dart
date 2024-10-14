/*
author: 이원영
Description: 네비게이션 바로 첨 보이는 채팅방 페이지
Fixed: 10/11
Usage: Navigation 4th page
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/chatroom.dart';
import 'package:vet_app/view/chat_view.dart';
import 'package:vet_app/vm/chat_handler.dart';

class ChatRoom extends StatelessWidget {

  ChatRoom({super.key});

  final ChatsHandler vmHandler = Get.find();
  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 1500), () {
      vmHandler.showScreen();
    });
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('상담'),
      ),
      body:vmHandler.rooms.isEmpty?
            const Center(child: CircularProgressIndicator(),):
            Obx(() => chatRoomList(context),)
    );
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
              await vmHandler.getStatus();
              await vmHandler.queryChat();
              Get.to(()=>ChatView(),
                  arguments: [room.image, vmHandler.roomName[index]])!.then((value) => vmHandler.queryLastChat());
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width / 1.5,
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      index < vmHandler.roomName.length ? vmHandler.roomName[index]
                                      :const Text(''),
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  // 마지막 채팅 실패
                                  // Row(
                                  //   children: [
                                  //     index <= vmHandler.lastChats.length-1 ? Text(vmHandler.lastChats[index].text): const Text('채팅이 없습니다.')
                                  //   ],
                                  // ),
                                  // Container(
                                  //   alignment: Alignment.bottomRight,
                                  //   width:
                                  //       MediaQuery.of(context).size.width / 1.5,
                                  //   child: index <= vmHandler.lastChats.length-1 ?    
                                  //   DateTime.now().difference(
                                  //     DateTime.parse(vmHandler.lastChats[index].timestamp)) < 
                                  //     const Duration(hours: 24)? 
                                  //     Text(
                                  //       vmHandler.lastChats[index].timestamp.substring(11, 16)
                                  //     ): 
                                  //     Text(
                                  //         "${vmHandler.lastChats[index].timestamp.substring(5, 7)}월 ${vmHandler.lastChats[index].timestamp.substring(8, 10)}일"): 
                                  //     const Text(''),
                                 
                                  // )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

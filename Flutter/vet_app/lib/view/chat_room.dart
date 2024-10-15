/*
author: 이원영
Description: 네비게이션 바로 첨 보이는 채팅방 페이지
Fixed: 10/14
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
        title: const Text(
          '채팅 상담',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: vmHandler.rooms.isEmpty
          ? _buildEmptyState()
          : Obx(() => _buildChatRoomList(context)),
    );
  }

  _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '상담하신 병원이 없습니다.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  _buildChatRoomList(BuildContext context) {
    return ListView.builder(
      itemCount: vmHandler.rooms.length,
      itemBuilder: (context, index) {
        Chatroom room = vmHandler.rooms[index];
        return _buildChatRoomItem(context, room, index);
      },
    );
  }

  _buildChatRoomItem(BuildContext context, Chatroom room, int index) {
    return GestureDetector(
      onTap: () async {
        vmHandler.currentClinicId.value = room.clinic;
        await vmHandler.getStatus();
        await vmHandler.queryChat();
        Get.to(() => ChatView(),
            arguments: [room.image, vmHandler.roomName[index]]);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  room.image,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      index < vmHandler.roomName.length
                          ? vmHandler.roomName[index]
                          : '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
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
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

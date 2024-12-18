/*
author: 이원영
Description: 네비게이션 바로 첨 보이는 채팅방 페이지
Fixed: 10/14
Usage: Navigation 4th page
*/

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Timer(const Duration(milliseconds: 1500), () {
      vmHandler.showScreen();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '채팅 상담',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(
        () => vmHandler.rooms.isEmpty
            ? _buildEmptyState(screenWidth)
            : ListView.builder(
                itemCount: vmHandler.rooms.length,
                itemBuilder: (context, index) {
                  Chatroom room = vmHandler.rooms[index];
                  return _buildChatRoomItem(context, room, screenWidth);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: screenWidth * 0.2,
            color: Colors.grey[400],
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            '상담하신 병원이 없습니다.',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomItem(
      BuildContext context, Chatroom room, double screenWidth) {
    return GestureDetector(
      onTap: () async {
        await vmHandler.getClinicId(room.clinic); // 현재 클리닉 ID 설정
        await vmHandler.getStatus(); // 상태 업데이트
        await vmHandler.queryChat();
        Get.to(() => ChatView(),
            arguments: [room.image, room.clinic, room.clinic]);
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.02,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: screenWidth * 0.18,
                  height: screenWidth * 0.18,
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  child: CachedNetworkImage(
                    imageUrl: room.image,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                      child: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.clinic,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      vmHandler.lastChatsMap[room.clinic]?.text ?? '채팅이 없습니다.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: screenWidth * 0.07,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

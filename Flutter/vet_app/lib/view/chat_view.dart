/*
author: 이원영
Description: 병원과 유저간 채팅 페이지
Fixed: 10/11
Usage: 채팅 목록
*/

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/chats.dart';
import 'package:vet_app/vm/chat_handler.dart';

class ChatView extends StatelessWidget {
  ChatView({super.key});

  final ChatsHandler vmHandler = Get.find();
  final TextEditingController chatController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    vmHandler.getStatus();
    final temp = Get.arguments ?? "__";
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.lightGreen[100],
          elevation: 0,
          toolbarHeight: 75,
          title: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(temp[0]),
              ),
              const SizedBox(width: 12), // 사진과 병원 이름 사이의 간격 조정
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temp[1],
                      overflow: TextOverflow.ellipsis, // 이름이 너무 길 경우 줄임표 처리
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    Obx(() => Text(
                          vmHandler.status.value ? '진료 중' : '진료 종료',
                          style: TextStyle(
                            color: vmHandler.status.value
                                ? Colors.green[400]
                                : Colors.red[400],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Expanded(
              child: Obx(
                () => _buildChatList(context, temp),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildChatList(BuildContext context, var temp) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      vmHandler.listViewContoller
          .jumpTo(vmHandler.listViewContoller.position.maxScrollExtent);
    });

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: vmHandler.listViewContoller,
            itemCount: vmHandler.chats.length,
            itemBuilder: (context, index) {
              Chats chat = vmHandler.chats[index];
              return _buildChatItem(context, chat, temp);
            },
          ),
        ),
        _buildInputField(context, temp),
      ],
    );
  }

  _buildChatItem(BuildContext context, Chats chat, var temp) {
    if (vmHandler.checkToday(chat)) {
      return _buildDateSeparator(chat);
    } else if (vmHandler.box.read('userEmail') == chat.sender) {
      return _buildSentMessage(context, chat);
    } else {
      return _buildReceivedMessage(context, chat, temp);
    }
  }

  _buildDateSeparator(Chats chat) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        chat.text.substring(3, 13),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
    );
  }

  _buildSentMessage(BuildContext context, Chats chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.timestamp.substring(11, 16),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                chat.text,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildReceivedMessage(BuildContext context, Chats chat, var temp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(temp[0]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temp[1],
                  overflow: TextOverflow.ellipsis, // 이름이 길 경우 줄임표 처리
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chat.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            chat.timestamp.substring(11, 16),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  _buildInputField(BuildContext context, var temp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: chatController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[300],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Colors.green,
            ),
            onPressed: () => inputChat(temp),
          ),
        ],
      ),
    );
  }

  inputChat(var temp) async {
    if (vmHandler.currentClinicId.isEmpty) {
      await vmHandler.getClinicName(temp[1]);
    }
    Chats inputchat = Chats(
      reciever: vmHandler.currentClinicId.value,
      sender: vmHandler.box.read('userEmail'),
      text: chatController.text.trim(),
      timestamp: DateTime.now().toString(),
    );
    if (chatController.text.isNotEmpty) {
      await vmHandler.addChat(inputchat);
    }
    chatController.clear();
  }
}

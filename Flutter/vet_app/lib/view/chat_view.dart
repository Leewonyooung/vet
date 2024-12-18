/*
author: 이원영
Description: 병원과 유저간 채팅 페이지
Fixed: 10/11
Usage: 채팅 목록
*/

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/chats.dart';
import 'package:vet_app/vm/chat_handler.dart';

class ChatView extends StatelessWidget {
  ChatView({super.key});

  final temp = Get.arguments ?? ['Default Image', 'Default Name'];
  final ChatsHandler vmHandler = Get.find();
  final TextEditingController chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    vmHandler.getStatus();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.lightGreen[100],
          elevation: 0,
          toolbarHeight: screenHeight * 0.1,
          title: Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.06,
                backgroundColor: Colors.grey[200],
                child: CachedNetworkImage(
                  imageUrl: temp[0],
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: screenWidth * 0.06,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, color: Colors.red),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temp[1],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
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
                            fontSize: screenWidth * 0.04,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Obx(() => _buildChatList(context, screenWidth)),
              ),
              _buildInputField(context, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context, double screenWidth) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      vmHandler.listViewContoller
          .jumpTo(vmHandler.listViewContoller.position.maxScrollExtent);
    });

    return ListView.builder(
      controller: vmHandler.listViewContoller,
      itemCount: vmHandler.chats.length,
      itemBuilder: (context, index) {
        Chats chat = vmHandler.chats[index];
        return _buildChatItem(context, chat, screenWidth);
      },
    );
  }

  Widget _buildChatItem(BuildContext context, Chats chat, double screenWidth) {
    if (vmHandler.checkToday(chat)) {
      return _buildDateSeparator(chat, screenWidth);
    } else if (vmHandler.box.read('userEmail') == chat.sender) {
      return _buildSentMessage(chat, screenWidth);
    } else {
      return _buildReceivedMessage(chat, screenWidth);
    }
  }

  Widget _buildDateSeparator(Chats chat, double screenWidth) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Text(
        chat.text.substring(3, 13),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: screenWidth * 0.04,
        ),
      ),
    );
  }

  Widget _buildSentMessage(Chats chat, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.01,
        horizontal: screenWidth * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.timestamp.substring(11, 16),
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                chat.text,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(Chats chat, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.01,
        horizontal: screenWidth * 0.04,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: screenWidth * 0.06,
            backgroundColor: Colors.grey[200],
            child: CachedNetworkImage(
              imageUrl: temp[0],
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: screenWidth * 0.06,
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.red),
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temp[1],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chat.text,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Text(
            chat.timestamp.substring(11, 16),
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenWidth * 0.01,
      ),
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
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.03,
                ),
              ),
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.send, color: Colors.green, size: screenWidth * 0.06),
            onPressed: () => inputChat(temp),
          ),
        ],
      ),
    );
  }

  void inputChat(List<String> temp) async {
    if (vmHandler.currentClinicId.isEmpty) {
      await vmHandler.getClinicName(temp[1]);
    }
    Chats inputChat = Chats(
      reciever: vmHandler.currentClinicId.value,
      sender: vmHandler.box.read('userEmail'),
      text: chatController.text.trim(),
      timestamp: DateTime.now().toString(),
    );
    if (chatController.text.isNotEmpty) {
      await vmHandler.addChat(inputChat);
    }
    chatController.clear();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:vet_tab/model/chatroom.dart';
import 'package:vet_tab/model/chats.dart';
import 'package:vet_tab/vm/chat_handler.dart';
import 'package:vet_tab/vm/login_handler.dart';

class ChatRoomView extends StatelessWidget {
  ChatRoomView({super.key});
  final ChatsHandler chatsHandler = Get.put(ChatsHandler());
  final TextEditingController chatController = TextEditingController();

  // 선택된 채팅방 인덱스를 관리하는 상태 변수
  final RxInt selectedChatIndex = (-1).obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder(
        future: chatsHandler.getAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('오류 발생: ${snapshot.error}'),
            );
          } else {
            return Obx(() => chatRoomList(context));
          }
        },
      ),
    );
  }

  Widget chatRoomList(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: chatsHandler.rooms.length,
              itemBuilder: (context, index) {
                Chatroom room = chatsHandler.rooms[index];
                return GestureDetector(
                  onTap: () async {
                    await chatsHandler.setcurrentUserId(room.user);
                    await chatsHandler.setcurrentRoomImage(room.image);
                    await chatsHandler.showChat();
                    await chatsHandler.queryChat();
                    selectedChatIndex.value = index; // 선택된 채팅방 인덱스 업데이트
                  },
                  child: Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        child: Card(
                          color: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: selectedChatIndex.value == index
                                  ? Colors.blue // 선택된 항목의 테두리 색상 변경
                                  : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(room.image),
                              radius: 30,
                            ),
                            title: Text(
                              chatsHandler.roomName[index],
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            subtitle: index < chatsHandler.lastChats.length
                                ? Text(
                                    chatsHandler.lastChats[index].text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  )
                                : const Text('채팅이 없습니다.',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey)),
                            trailing: index < chatsHandler.lastChats.length
                                ? Text(
                                    DateTime.now().difference(DateTime.parse(
                                                chatsHandler.lastChats[index]
                                                    .timestamp)) <
                                            const Duration(hours: 24)
                                        ? chatsHandler
                                            .lastChats[index].timestamp
                                            .substring(11, 16)
                                        : "${chatsHandler.lastChats[index].timestamp.substring(5, 7)}월 ${chatsHandler.lastChats[index].timestamp.substring(8, 10)}일",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  )
                                : null,
                          ),
                        ),
                      )),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: chatsHandler.chatShow.value
              ? chatDetail(context, )
              : const Center(child: Text('채팅을 선택하세요')),
        ),
      ],
    );
  }

  Widget chatDetail(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            chatsHandler.currentUserName.value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: chatList(context),
        ),
        chatInputField(context),
      ],
    );
  }

  Widget chatList(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      chatsHandler.listViewContoller
          .jumpTo(chatsHandler.listViewContoller.position.maxScrollExtent);
    });

    return ListView.builder(
      controller: chatsHandler.listViewContoller,
      itemCount: chatsHandler.chats.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        Chats chat = chatsHandler.chats[index];

        if (chatsHandler.checkToday(chat)) {
          String date = chat.text.substring(3, 13);
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                date,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        bool isSender = chat.sender == Get.find<LoginHandler>().box.read('id');
        return Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSender ? Colors.blueGrey[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(chat.text, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Text(chat.timestamp.substring(11, 16),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget chatInputField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: chatController,
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => inputChat(),
            icon: const Icon(Icons.send, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  inputChat() async {
    if (chatController.text.trim().isEmpty) return;

    Chats newChat = Chats(
      reciever: chatsHandler.currentUserId.value,
      sender: Get.find<LoginHandler>().box.read('id'),
      text: chatController.text.trim(),
      timestamp: DateTime.now().toString(),
    );
    await chatsHandler.addChat(newChat);
    chatController.clear();
  }
}

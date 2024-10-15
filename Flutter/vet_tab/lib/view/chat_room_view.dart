import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:vet_tab/model/chatroom.dart';
import 'package:vet_tab/model/chats.dart';
import 'package:vet_tab/vm/chat_handler.dart';

class ChatRoomView extends StatelessWidget {
  ChatRoomView({super.key});
  final ChatsHandler chatsHandler = Get.put(ChatsHandler());
  final TextEditingController chatController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              return 
              Obx(() => chatRoomList(context),);
          }
        },
      )
    );
  }


chatRoomList(context) {
return Row(
  children: [
    SizedBox(
      width:MediaQuery.of(context).size.width / 2.5,
      height: MediaQuery.of(context).size.height / 1.1,
      child: ListView.builder(
        itemCount: chatsHandler.rooms.length,
        itemBuilder: (context, index) {
          Chatroom room = chatsHandler.rooms[index];
          // print(room);
          return GestureDetector(
            onTap: () async {
              // print(room.user);
              // await chatsHandler.setCurrentUserName(chatsHandler.roomName[index]);
              await chatsHandler.setcurrentUserId(room.user);
              await chatsHandler.setcurrentRoomImage(room.image);
              await chatsHandler.showChat();
              await chatsHandler.queryChat();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  height: MediaQuery.of(context).size.height / 7,
                  child: Row(
                    children: [
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15)),
                                  width: MediaQuery.of(context).size.width/10,
                                  height: MediaQuery.of(context).size.width/10,
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
                                      chatsHandler.roomName[index],
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                    // Row(
                                    //   children: [
                                    //     index <= chatsHandler.lastChats.length-1 ?
                                    //     Text(chatsHandler.lastChats[index].text,style: const TextStyle(fontSize: 22)):const Text('채팅이 없습니다.')
                                    //   ],
                                    // ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      width: MediaQuery.of(context).size.width /4,
                                      child: index <= chatsHandler.lastChats.length-1 ?    
                                    DateTime.now().difference(
                                      DateTime.parse(chatsHandler.lastChats[index].timestamp)) < 
                                      const Duration(hours: 24)? 
                                      Text(
                                        chatsHandler.lastChats[index].timestamp.substring(11, 16)
                                      ): 
                                      Text(
                                          "${chatsHandler.lastChats[index].timestamp.substring(5, 7)}월 ${chatsHandler.lastChats[index].timestamp.substring(8, 10)}일"): 
                                      const Text(''),
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
        ),
        !chatsHandler.chatShow.value?const SizedBox()
        : Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          width: MediaQuery.of(context).size.width/1.9,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top:15.0,bottom: 10),
                child: SizedBox(
                  child: Text(chatsHandler.currentUserName.value,style: const TextStyle(fontSize: 40),),
                ),
              ),
              chatList(context,),
               Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(15))
                ),
                height: MediaQuery.of(context).size.height / 14,
                width: MediaQuery.of(context).size.width / 2,
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                      ),
                      width: MediaQuery.of(context).size.width / 2.2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: chatController,
                          decoration:const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25))), ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => inputChat(),
                      icon: const Icon(Icons.arrow_circle_up_outlined),
                    ),
                  ],
                ),
              )
            ],
          )
        ),
        // chatsHandler.chatShow.value == false ? const SizedBox():
        // Text(chatsHandler.chats[0].sender)
      ],
    );
  }


  Widget chatList(context, ) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      chatsHandler.listViewContoller
          .jumpTo(chatsHandler.listViewContoller.position.maxScrollExtent);
    });
    return Column(
      children: [
        SizedBox(
          // width: MediaQuery.of(context).size.width/1.9,
          height: MediaQuery.of(context).size.height / 1.22,
          child: ListView.builder(
            controller: chatsHandler.listViewContoller,
            itemCount: chatsHandler.chats.length,
            itemBuilder: (context, index) {
              Chats chat = chatsHandler.chats[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  // width: MediaQuery.of(context).size.width/3,
                  child: chatsHandler.checkToday(chat)?
                  Container(
                    // width: MediaQuery.of(context).size.width/3,
                    alignment: Alignment.center,
                    child: Text(chat.text.substring(3,13), style: const TextStyle(fontSize: 18,),),
                  ):
                  'adfki125' == chat.sender? 
                  Padding(
                    padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/10,0,0,0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text(chat.timestamp.substring(11,16)),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green[200],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child:
                                  SizedBox(
                                    child: Text(
                                      chat.text,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                  padding: const EdgeInsets.only(right:15.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: Image.network(
                                chatsHandler.currentRoomImage.value,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left:8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width/2.3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(chatsHandler.currentUserName.value, style: const TextStyle(fontSize: 20),),
                                    chat.text.length == chatsHandler.checkToday(chat)?
                                    Text(chat.text.substring(3,chat.text.length-4)):
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green[200],
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Text(
                                                chat.text,
                                                style: const TextStyle(fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left:8.0),
                                          child: Text(chat.timestamp.substring(11,16)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  inputChat() async {
    Chats inputchat = Chats(
      reciever: chatsHandler.currentUserId.value,
      sender: 'adfki125',
      text: chatController.text.trim(),
      timestamp: DateTime.now().toString(),
    );
    if (chatController.text != "" && chatController.text.isNotEmpty) {
      await chatsHandler.addChat(inputchat);
    }
    chatController.text = '';
  }

}
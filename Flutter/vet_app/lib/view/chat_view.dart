import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/chats.dart';
import 'package:vet_app/vm/chat_handler.dart';

class ChatView extends StatelessWidget {
  ChatView({super.key,});
  final ChatsHandler vmHandler = Get.find();
  final TextEditingController chatController = TextEditingController();
  final value = Get.arguments??"__";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(value[1]),
        actions: [
          IconButton(
            onPressed: () {
              //
            },
            icon: const Icon(Icons.search_outlined),
          )
        ],
      ),
      body: Obx(() {
        return chatList(context);
      }),
    );
  }

  chatList(context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      vmHandler.listViewContoller
          .jumpTo(vmHandler.listViewContoller.position.maxScrollExtent);
    });
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.35,
          child: ListView.builder(
            controller: vmHandler.listViewContoller,
            itemCount: vmHandler.chats.length,
            itemBuilder: (context, index) {
              Chats chat = vmHandler.chats[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: vmHandler.checkToday(chat)?
                  Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text(chat.text.substring(3,13), style: const TextStyle(fontSize: 18,),),
                  ):
                  vmHandler.box.read('userEmail') == chat.sender? 
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
                                value[0],
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
                                width: MediaQuery.of(context).size.width/1.4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(value[1],style: const TextStyle(fontSize: 20),),
                                    chat.text.length == vmHandler.checkToday(chat)?
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
        Container(
          decoration: const BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(15))
          ),
          height: MediaQuery.of(context).size.height / 14,
          width: MediaQuery.of(context).size.width / 1.1,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  
                ),
                width: MediaQuery.of(context).size.width / 1.3,
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
    );
  }

  inputChat() async {
    Chats inputchat = Chats(
      reciever: vmHandler.currentClinicId.value,
      sender: vmHandler.box.read('userEmail'),
      text: chatController.text.trim(),
      timestamp: DateTime.now().toString(),
    );
    if (chatController.text != "" && chatController.text.isNotEmpty) {
      
      await vmHandler.addChat(inputchat);
    }
    chatController.text = '';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/chats.dart';
import 'package:vet_app/vm/vm_handler.dart';

class ChatView extends StatelessWidget {
  ChatView({super.key, });
  final VmHandler vmHandler = Get.find();
  final TextEditingController chatController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상담'),
        actions: [
          IconButton(
            onPressed: () {
              //
            }, 
            icon: const Icon(Icons.search_outlined),
          )
        ],
      ),
      body: Obx(() {return chatList(context);}
      ),
    );
  }
  

  chatList(context){
    SchedulerBinding.instance.addPostFrameCallback((_) {
      vmHandler.listViewContoller
      	.jumpTo(vmHandler.listViewContoller.position.maxScrollExtent);
    });
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height/1.35,
          child: ListView.builder(
            controller: vmHandler.listViewContoller,
            itemCount: vmHandler.chats.length,
            itemBuilder: (context, index) {
              Chats chat = vmHandler.chats[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: vmHandler.box.read('userId')==chat.sender?Row(
                    mainAxisAlignment:MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                chat.text,
                                style: const TextStyle(
                                  fontSize: 22
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ):
                  Row(
                    mainAxisAlignment:MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                chat.text,
                                style: const TextStyle(
                                  fontSize: 22
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
          height: MediaQuery.of(context).size.height /14,
          width: MediaQuery.of(context).size.width /1.1,
          child: Row(
            children: [
              SizedBox(
                width:  MediaQuery.of(context).size.width /1.3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: chatController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder()
                    ),
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

  inputChat() async{
    Chats inputchat = Chats(
      reciever: vmHandler.currentClinicId.value,
      sender:vmHandler.box.read('userId'),
      text:chatController.text.trim(),
      timestamp: DateTime.now().toString(),
      );
    if(chatController.text !="" && chatController.text.isNotEmpty){
      await vmHandler.addChat(inputchat);
    }
    chatController.text='';
  }


}
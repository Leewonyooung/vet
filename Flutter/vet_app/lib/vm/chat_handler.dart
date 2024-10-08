import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vet_app/model/chatroom.dart';
import 'package:vet_app/model/chats.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/treatment_handler.dart';

class ChatsHandler extends TreatmentHandler{
  final chats = <Chats>[].obs;
  final rooms = <Chatroom>[].obs;
  final currentClinicId = "".obs;
  final imagePath = [].obs;
  final lastchatroom = <Chatroom>[].obs;
  final lastChats = <Chats>[].obs;

  List <Chatroom> result = [];
  ScrollController listViewContoller = ScrollController();

  final CollectionReference _rooms= FirebaseFirestore.instance.collection('chat');


  @override
  void onInit() async{
    super.onInit();
    await makeChatRoom();
    await queryLastChat();
  }
  

  queryChat(){
    _rooms.doc("${currentClinicId.value}_${box.read('userId')}").collection('chats').orderBy('timestamp',descending: false).snapshots().listen((event) {
        chats.value = event.docs.map(
          (doc) => Chats.fromMap(doc.data(), doc.id),
        ).toList();
      },
    );
  }

  queryLastChat() async{
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection("chat").get();
    var tempresult = snapshot.docs.map((doc) => doc.data()).toList();
    for(int i = 0; i < tempresult.length; i++){
      Chatroom chatroom = Chatroom(clinic: tempresult[i]['clinic'], user: tempresult[i]['user'], image: tempresult[i]['image']);
      result.add(chatroom);
    }
    for(int i = 0; i < result.length; i++){
      _rooms.doc("${result[i].clinic}_${box.read('userId')}").collection('chats').orderBy('timestamp',descending: false).limit(1).snapshots().listen((event) {
        for(int i = 0; i < event.docs.length; i++){
          var chat = event.docs[i].data();
          lastChats.add(Chats(reciever: chat['reciever'], sender: chat['sender'], text: chat['text'], timestamp: chat['timestamp']));
        }
      },);
    }
  }

  makeChatRoom() async{
    _rooms.snapshots().listen((event) {
        rooms.value = event.docs.map(
          (doc) => Chatroom(clinic: doc.get('clinic'), user: doc.get('user'), image: doc.get('image')),
        ).toList();
      }
    );
  }

  addChat(Chats chat){
    _rooms.doc("${currentClinicId.value}_${box.read('userId')}").collection('chats').add(
      {
        'reciever' : chat.reciever,
        'sender': chat.sender,
        'text':chat.text,
        'timestamp':chat.timestamp,
      } 
    );
  }
}
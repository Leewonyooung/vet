import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
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

  queryLastChat(){
    List <Chatroom> result = [];
    _rooms.snapshots().listen((event) {
      event.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>; 
        print(data);
        Chatroom chatroom = Chatroom(clinic: data['clinic'], user: data['user'], image: data['image']);
        print(chatroom);
        result.add(chatroom);
        print(result);
        });
        },
        // (doc) => Chatroom(clinic: doc.get('clinic'), user: doc.get('user'), image: doc.get('image')),).toList();
      );
      lastchatroom.value = result;
    print(lastchatroom);
    _rooms.doc('123_1234').collection('chats').orderBy('timestamp',descending: true).snapshots().listen((event) {
      print(event.docs.first.data());
      // print(event.docs.map((doc) =>  Chats.fromMap(doc.data(), doc.id),).toList());
      lastChats.value = event.docs.map((doc) =>  Chats.fromMap(doc.data(), doc.id),).toList();
      },
    );
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
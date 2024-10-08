import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vet_app/model/chatroom.dart';
import 'package:vet_app/model/chats.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/treatment_handler.dart';
import 'package:http/http.dart' as http;

class ChatsHandler extends TreatmentHandler{
  final chats = <Chats>[].obs;
  final rooms = <Chatroom>[].obs;
  final currentClinicId = "".obs;
  final lastchatroom = <Chatroom>[].obs;
  final lastChats = <Chats>[].obs;
  final roomName= [].obs;

  List <Chatroom> result = [];
  ScrollController listViewContoller = ScrollController();

  final CollectionReference _rooms= FirebaseFirestore.instance.collection('chat');

  queryChat(){
    _rooms.doc("${currentClinicId.value}_${box.read('userId')}").collection('chats').orderBy('timestamp',descending: true).snapshots().listen((event) {
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
          lastChats.obs.value.add(Chats(reciever: chat['reciever'], sender: chat['sender'], text: chat['text'], timestamp: chat['timestamp']));
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

  getlastName() async{
    List idList = [];
    for(int i = 0; i < result.length; i++){
      idList.add(result[i].clinic);
    }
    for(int i = 0; i < idList.length; i++){
      var url = Uri.parse('http://127.0.0.1:8000/clinic/select_clinic_name?name=${idList[i]}');
      var response = await http.get(url);
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      roomName.obs.value.add(dataConvertedJSON['results'][0].toString());
    }
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
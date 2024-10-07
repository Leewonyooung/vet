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
    print('run');
    _rooms.doc("${currentClinicId.value}_${box.read('userId')}").collection('chats').snapshots().distinct().listen((event) {
      print(event.docs);
        lastChats.value = event.docs.map(
          (doc) => Chats(
            reciever: doc.get('reciever'), 
            sender: doc.get('sender'), 
            text: doc.get('text'), 
            timestamp: doc.get('timestamp')
          ),
        ).toList();
      },
    );
  }

  // preparingImage()async{
  //   final firebaseStorage = FirebaseStorage.instance.ref().child('images').child("${codeController.text}.png");
  //   await firebaseStorage.putFile(imgFile!);
  //   String downloadURL = await firebaseStorage.getDownloadURL();
  //   return downloadURL;
  // }

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
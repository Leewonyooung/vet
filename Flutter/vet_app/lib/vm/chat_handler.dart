import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vet_app/model/chatroom.dart';
import 'package:vet_app/model/chats.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:http/http.dart' as http;

class ChatsHandler extends LoginHandler {
  final show = false.obs;
  final chats = <Chats>[].obs;
  final rooms = <Chatroom>[].obs;
  final currentClinicId = "".obs;
  final lastchatroom = <Chatroom>[].obs;
  final lastChats = <Chats>[].obs;
  final roomName = [].obs;
  Stream<QuerySnapshot> testsnapshot =  FirebaseFirestore.instance.collection("chat").where('clinic',isEqualTo: 'adfki125').snapshots();
  List<Chatroom> result = [];
  ScrollController listViewContoller = ScrollController();

  final CollectionReference _rooms =
      FirebaseFirestore.instance.collection('chat');

  @override
  void onInit() async {
    super.onInit();
    await getAllData();
  }
  showScreen() async{
    show.value = true;
    update();
  }
  getAllData() async{
    await makeChatRoom();
    await queryLastChat();
    await getlastName();
  }

  getClinicName(String name) async{
     var url = Uri.parse(
          'http://127.0.0.1:8000/clinic/getclinicname?name=$name');
      var response = await http.get(url);
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    currentClinicId.value = dataConvertedJSON['results'][0];
    update();
  }

  queryChat() {
    _rooms
        .doc("${currentClinicId.value}_${box.read('userEmail')}")
        .collection('chats')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen(
      (event) {
        chats.value = event.docs
            .map(
              (doc) => Chats.fromMap(doc.data(), doc.id),
            )
            .toList();
      },
    );
  }

  queryLastChat() async {
    // List<Chats> returnResult=[];
    // FirebaseFirestore.instance.collection("chat").where('user',isEqualTo: box.read('userEmail')).snapshots().listen((parent) {for(var parentdoc in parent.docs){
    //   _rooms
    //       .doc(parentdoc.id)
    //       .collection('chats')
    //       .orderBy('timestamp', descending: true)
    //       .limit(1)
    //       .snapshots().listen((sub) {
    //         for(var subdoc in sub.docs){
    //           var chat = subdoc.data();
    //           returnResult.add(Chats(
    //             reciever: chat['reciever'],
    //             sender: chat['sender'],
    //             text: chat['text'],
    //             timestamp: chat['timestamp']));
    //         }
    //         lastChats.value = returnResult;
    //       },);
    // }});
    List<Chats> returnResult=[];
    result.clear();
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection("chat").where('user',isEqualTo: box.read('userEmail')).get();
    var tempresult = snapshot.docs.map((doc) => doc.data()).toList();
    for (int i = 0; i < tempresult.length; i++) {
      Chatroom chatroom = Chatroom(
          clinic: tempresult[i]['clinic'],
          user: tempresult[i]['user'],
          image: tempresult[i]['image']);
      result.add(chatroom);
    }
    for (int i = 0; i < result.length; i++) {
      _rooms
          .doc("${result[i].clinic}_${box.read('userEmail')}")
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen(
        (event) {
          for (int i = 0; i < event.docs.length; i++) {
            var chat = event.docs[i].data();
            returnResult.add(Chats(
                reciever: chat['reciever'],
                sender: chat['sender'],
                text: chat['text'],
                timestamp: chat['timestamp']));
          }
          lastChats.value = returnResult;
        },
      );
    }
  }

  firstChatRoom(id, image) async{
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/clinic/view/$image'));
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/temp_image.jpg';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    final firebaseStorage = FirebaseStorage.instance.ref().child("$image");
    await firebaseStorage.putFile(file);
    String downloadURL = await firebaseStorage.getDownloadURL();

   _rooms
        .doc("${id}_${box.read('userEmail')}")
        // .collection('chats')
        .set({
      'clinic': id,
      'image': downloadURL,
      'user': box.read('userEmail'),
    });
  }

  makeChatRoom() async {
    _rooms.where('user',isEqualTo: box.read('userEmail')).snapshots().listen((event) {
      rooms.value = event.docs
          .map(
            (doc) => Chatroom(
                clinic: doc.get('clinic'),
                user: doc.get('user'),
                image: doc.get('image')),
          )
          .toList();
    });
  }

  getlastName() async {
    List idList = [];
    for (int i = 0; i < result.length; i++) {
      idList.add(result[i].clinic);
    }
    for (int i = 0; i < idList.length; i++) {
      var url = Uri.parse(
          'http://127.0.0.1:8000/clinic/select_clinic_name?name=${idList[i]}');
      var response = await http.get(url);
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      roomName.obs.value.add(dataConvertedJSON['results'][0].toString());
    }
  }

  isToday() async {
    if(chats.isEmpty){
      return false;
    }
    bool istoday = true;
    chats[chats.length-1].timestamp.toString().substring(0,10) == DateTime.now().toString().substring(0,10)?
    istoday : istoday = false;
    return istoday;
  }

  checkToday(Chats chat) {
    return chat.text.length == 17 &&
        chat.text.substring(0, 3) == "set" &&
        chat.text.substring(13, 17) == "time";
  }

  addChat(Chats chat) async {
    bool istoday = await isToday();
    if (!istoday) {
      await _rooms
        .doc("${currentClinicId.value}_${box.read('userEmail')}")
        .collection('chats')
        .add({
      'reciever': chat.reciever,
      'sender': chat.sender,
      'text': "set${DateTime.now().toString().substring(0,10)}time",
      'timestamp': DateTime.now().toString(),
    });
    await queryLastChat();
    }

    _rooms
        .doc("${currentClinicId.value}_${box.read('userEmail')}")
        .collection('chats')
        .add({
      'reciever': chat.reciever,
      'sender': chat.sender,
      'text': chat.text,
      'timestamp': DateTime.now().toString(),
    });
    queryLastChat();
  }
}

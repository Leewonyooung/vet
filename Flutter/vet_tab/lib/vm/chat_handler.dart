import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vet_tab/model/chatroom.dart';
import 'package:vet_tab/model/chats.dart';
import 'package:vet_tab/vm/clinic_handler.dart';
import 'package:vet_tab/vm/login_handler.dart';

class ChatsHandler extends ClinicHandler {
  final chats = <Chats>[].obs;
  final rooms = <Chatroom>[].obs;
  final currentUserId = "".obs;
  final currentUserName = "".obs;
  final currentClinicName = ''.obs;
  final lastchatroom = <Chatroom>[].obs;
  final lastChats = <Chats>[].obs;
  final roomName = [].obs;
  RxBool chatShow = false.obs;
  RxString currentRoomImage = "".obs;
  Timer? _timer;

  List<Chatroom> result = [];
  ScrollController listViewContoller = ScrollController();

  final CollectionReference _rooms =
      FirebaseFirestore.instance.collection('chat');

  @override
  void onInit() async {
    super.onInit();
    startTimer();
  }
   void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      queryLastChat(); // 1초마다 실행할 함수
    });
  }

  @override
  void onClose() {
    _timer?.cancel(); // 타이머 종료
    super.onClose();
  }

  getAllData() async {
    await makeChatRoom();
    await queryLastChat();
    await queryChat();
    await getlastName();
    update();
  }

  setcurrentRoomImage(String path) {
    currentRoomImage.value = path;
    update();
  }

  setcurrentUserId(userId) {
    currentUserId.value = userId;
    update();
  }

  setCurrentUserName(String id) async {
    currentUserName.value = id;
    update();
  }

  setcurrentClinicName(String id) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/clinic/select_clinic_name?name=$id');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    roomName.obs.value.add(dataConvertedJSON['results'][0].toString());
    currentClinicName.value = id;
    update();
  }

  showChat() async {
    chatShow.value = true;
    update();
  }

  queryChat() async {
    _rooms
        .doc(
            "${Get.find<LoginHandler>().box.read('id')}_${currentUserId.value}")
        .collection('chats')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen(
      (event) async {
        chats.value = event.docs
            .map(
              (doc) => Chats.fromMap(doc.data(), doc.id),
            )
            .toList();
      },
    );
    update();
  }

  queryLastChat() async {
    List<Chats> returnResult = [];
    if (result.isNotEmpty) {
      result.clear();
    }
    if(returnResult.isNotEmpty){
      returnResult.clear();
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("chat")
        .where('clinic', isEqualTo: Get.find<LoginHandler>().box.read('id'))
        .get();
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
          .doc("${Get.find<LoginHandler>().box.read('id')}_${result[i].user}")
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
    update();
  }

  makeChatRoom() async {
    _rooms
        .where('clinic', isEqualTo: Get.find<LoginHandler>().box.read('id'))
        .snapshots()
        .listen((event) {
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
      if (idList.contains(result[i]) == false) {
        idList.add(result[i].user);
      }
    }
    for (int i = 0; i < idList.length; i++) {
      var url = Uri.parse(
          'http://127.0.0.1:8000/user/get_user_name?id=${idList[i]}');
      var response = await http.get(url);
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      roomName.obs.value.add(dataConvertedJSON['results'][0].toString());
    }
  }

  isToday() async {
    bool istoday = true;
    chats[chats.length - 1].timestamp.toString().substring(0, 10) ==
            DateTime.now().toString().substring(0, 10)
        ? istoday
        : istoday = false;
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
          .doc(
              "${Get.find<LoginHandler>().box.read('id')}_${currentUserId.value}")
          .collection('chats')
          .add({
        'reciever': chat.reciever,
        'sender': chat.sender,
        'text': "set${DateTime.now().toString().substring(0, 10)}time",
        'timestamp': DateTime.now().toString(),
      });
    }

    _rooms
        .doc(
            "${Get.find<LoginHandler>().box.read('id')}_${currentUserId.value}")
        .collection('chats')
        .add({
      'reciever': chat.reciever,
      'sender': chat.sender,
      'text': chat.text,
      'timestamp': DateTime.now().toString(),
    });
  }
}

import 'dart:async';
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
  RxString currentClinicId = "".obs;
  final lastchatroom = <Chatroom>[].obs;
  final lastChats = <Chats>[].obs;
  final status = false.obs;
  final roomName = [].obs;
  List<Chatroom> result = [];
  ScrollController listViewContoller = ScrollController();
  RxMap<String, Chats?> lastChatsMap = <String, Chats?>{}.obs; 
  final CollectionReference _rooms =
      FirebaseFirestore.instance.collection('chat');
  Timer? _timer;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // queryLastChat(); // 1초마다 실행할 함수
      makeChatRoom();
    });
  }

  @override
  void onClose() {
    _timer?.cancel(); // 타이머 종료
    super.onClose();
  }

  @override
  void onInit() async {
    super.onInit();
    // await getAllData();
    startTimer();
  }

  checkLength() async {
    if (rooms.length < roomName.length) {
      roomName.clear();
      getAllData();
    }
    update();
  }

  chatsClear() async {
    rooms.clear();
    chats.clear();
    roomName.clear();
    lastChats.clear();
    lastchatroom.clear();
  }

  DateTime parseTime(String timeStr) {
    bool isPM = timeStr.contains("오후");
    timeStr = timeStr.replaceRange(0, 2, '');
    List<String> timeParts = timeStr.split(":");

    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

 getStatus() async {
  if (currentClinicId.isEmpty) {
    status.value = false; // 기본 상태 설정
    update();
    return;
  }

  try {
    var url = Uri.parse('$server/clinic/detail_clinic?id=$currentClinicId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));

      if (dataConvertedJSON['results'] == null ||
          dataConvertedJSON['results'].isEmpty) {
        print('Error: No results found in the response.');
        status.value = false; // 기본 상태 설정
        update();
        return;
      }

      // JSON에서 시간 정보 추출
      String? startTime = dataConvertedJSON['results'][0][5];
      String? endTime = dataConvertedJSON['results'][0][6];

      if (startTime == null || endTime == null) {
        status.value = false; // 기본 상태 설정
        update();
        return;
      }

      // 시간 파싱
      DateTime time1 = parseTime(startTime);
      DateTime time2 = parseTime(endTime);

      // 시간 비교
      if (DateTime.now().isAfter(time1) && DateTime.now().isBefore(time2)) {
        status.value = true;
      } else {
        status.value = false;
      }
    } else {
      print('Error: HTTP request failed with status ${response.statusCode}.');
      status.value = false; // 기본 상태 설정
    }
  } catch (e) {
    print('Error in getStatus: $e');
    status.value = false; // 기본 상태 설정
  }

  update();
}


  showScreen() async {
    show.value = true;
    update();
  }

  getAllData() async {
    await makeChatRoom();
  }

  getClinicId(String name) async {
    var url =
        Uri.parse('$server/clinic/get_clinic_name?name=$name');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    currentClinicId.value = dataConvertedJSON['results'][0];
    update();
  }

  getClinicName(String name) async {
    var url =
        Uri.parse('$server/clinic/getclinicname?name=$name');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    currentClinicId.value = dataConvertedJSON['results'][0];
    update();
  }

  queryChat() {
    _rooms.doc("${currentClinicId.value}_${box.read('userEmail')}")
        .snapshots()
        .listen(
      (event) {
        List<dynamic> messages = event.get('chats') ?? [];
        List<Chats> mappedMessages = messages
            .map((message) =>
                Chats.fromMap(message as Map<String, dynamic>, event.id))
            .toList();
        mappedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        chats.value = mappedMessages;
      },
    );
  }


  firstChatRoom(id, name, image) async {
    final response =
        await http.get(Uri.parse('$server/clinic/view/$image'));
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/temp_image';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    final firebaseStorage = FirebaseStorage.instance.ref().child("$image");
    await firebaseStorage.putFile(file);
    String downloadURL = await firebaseStorage.getDownloadURL();
    _rooms
        .doc("${id}_${box.read('userEmail')}")
        .set({
      'clinic': name,
      'image': downloadURL,
      'user': mypageUserInfo[0].name,
      'chats':[]
    });
    roomName.clear();
    // getAllData();

    update();
    return downloadURL;
  }


makeChatRoom() async {
  _rooms
      .where('user', isEqualTo: box.read('userName'))
      .snapshots()
      .listen((event) async {
    rooms.value = event.docs
        .map((doc) => Chatroom(
              clinic: doc.get('clinic'),
              user: doc.get('user'),
              image: doc.get('image'),
            ))
        .toList();

    // 병렬 처리
    final futures = event.docs.map((doc) async {
      String clinicId = doc.get('clinic');
      final tempLastChatsMap = <String, Chats?>{};
      try {
        var docData = doc.data() as Map<String, dynamic>?;
        if (docData != null) {
          List<dynamic> chatsList = (docData['chats'] ?? []) as List<dynamic>; // `chats`가 없으면 빈 배열로 처리
          if (chatsList.isNotEmpty) {
            List<Chats> mappedChats = chatsList
                .map((chat) => Chats.fromMap(chat as Map<String, dynamic>, ''))
                .toList();
            mappedChats.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            tempLastChatsMap[clinicId] =
                mappedChats.isNotEmpty ? mappedChats.last : null;
          } else {
            tempLastChatsMap[clinicId] = null; // 빈 배열일 경우
          }
        } else {
          tempLastChatsMap[clinicId] = null; // `docData`가 없을 경우
        }
      } catch (e) {
        tempLastChatsMap[clinicId] = null;
      }

      return {
        'lastChatsMap': tempLastChatsMap,
      };
    });

    final results = await Future.wait(futures);

    // 병렬 처리 결과 합치기
    final combinedLastChatsMap = <String, Chats?>{};

    for (var result in results) {
      combinedLastChatsMap.addAll(result['lastChatsMap'] as Map<String, Chats?>);
    }

    // 데이터 업데이트
    lastChatsMap.value = combinedLastChatsMap;
    update(); // 상태 업데이트
  });
}





  isToday() async {
    if (chats.isEmpty) {
      return false;
    }
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
          .doc("${currentClinicId.value}_${box.read('userEmail')}")
          .update({
        'chats': FieldValue.arrayUnion([
          {
            'sender': chat.sender,
            'text': "set${DateTime.now().toString().substring(0, 10)}time",
            'timestamp': DateTime.now().toString()
          }
        ])
      });
    }
    _rooms.doc("${currentClinicId.value}_${box.read('userEmail')}").update({
      'chats': FieldValue.arrayUnion([
        {
          'sender': chat.sender,
          'text': chat.text,
          'timestamp': DateTime.now().toString()
        }
      ])
    });
  }
}

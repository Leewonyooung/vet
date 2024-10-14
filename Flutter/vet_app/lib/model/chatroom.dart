import 'package:cloud_firestore/cloud_firestore.dart';

class Chatroom {
  String clinic;
  String user;
  String image;

  Chatroom({
    required this.clinic,
    required this.user,
    required this.image,
  });

  factory Chatroom.fromMap(Map<String, dynamic> map, String id) {
    return Chatroom(
      clinic: map['clinic'] ?? '',
      user: map['user'] ?? '',
      image: map['image'] ?? '',
    );
  }

  factory Chatroom.fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    Map<String, dynamic> data =
        doc.data() as Map<String, dynamic>; // 문서 데이터를 맵으로 가져오기

    return Chatroom(
      clinic: data['clinic'] ?? '', // Firestore의 'clinic' 필드를 클래스 필드에 매핑
      user: data['user'] ?? '', // 'user' 필드 매핑
      image: data['image'] ?? '', // 'image' 필드 매핑
    );
  }
}

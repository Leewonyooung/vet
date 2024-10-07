class Chatroom {
  String clinic;
  String user;
  String image;

  Chatroom({
    required this.clinic,
    required this.user,
    required this.image,
  });

  factory Chatroom.fromMap(Map<String, dynamic>map, String id){
    return Chatroom(
      clinic: map['clinic']??'',
      user: map['user']??'',
      image: map['image'],
    );
  }
}
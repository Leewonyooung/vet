class Chats {
  String reciever;
  String sender;
  String text; //0 : user 1 : clinic 2: content
  String timestamp;

  Chats({
    required this.reciever,
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  factory Chats.fromMap(Map<String, dynamic>map, String id){
    return Chats(
      reciever: map['reciever']??'',
      sender: map['sender']??'',
      text: map['text']?? '',
      timestamp: map['timestamp']??''
    );
  }
}
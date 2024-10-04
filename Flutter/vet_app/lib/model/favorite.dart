class Favorite {
  String? id;
  String userId;
  String clinicId;
  String name;
  String password;
  double latitude;
  double longitude;
  String startTime;
  String endTime;
  String introduction;
  String address;
  String phone;

  Favorite({
    this.id,
    required this.userId,
    required this.clinicId,
    required this.name,
    required this.password,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    required this.introduction,
    required this.address,
    required this.phone
  });
}
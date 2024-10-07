class Clinic {
  String? id;
  String name;
  String password;
  double latitude;
  double longitude;
  String startTime;
  String endTime;
  String introduction;
  String address;
  String phone;
  String image;

  Clinic({
    this.id,
    required this.name,
    required this.password,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    required this.introduction,
    required this.address,
    required this.phone,
    required this.image,
  });

  Clinic.fromMap(Map<dynamic, dynamic> res):
    id = res['id'],
    name = res['name'],
    password = res['password'],
    latitude = res['latitude'],
    longitude = res['longitude'],
    startTime = res['start_time'],
    endTime = res['end_time'],
    introduction = res['introduction'],
    address = res['address'],
    phone = res['phone'],
    image = res['image']??'';

}
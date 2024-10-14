class SearchReservations {
  String userId;
  String clinic_name;
  String clinic_latitude;
  String clinic_longitude;
  String time;
  String clinic_address;

  SearchReservations(
      {required this.userId,
      required this.clinic_name,
      required this.clinic_latitude,
      required this.clinic_longitude,
      required this.time,
      required this.clinic_address});
}

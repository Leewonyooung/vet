class SearchReservations {
  String clinicId;
  String clinicName;
  double latitude;
  double longitude;
  String time;
  String address;

  SearchReservations(
      {required this.clinicId,
      required this.clinicName,
      required this.latitude,
      required this.longitude,
      required this.time,
      required this.address});
}

class Reservation {
  int? seq;
  String userId;
  String clinicId;
  String time;
  String symptoms;

  Reservation({
    this.seq,
    required this.userId,
    required this.clinicId,
    required this.time,
    required this.symptoms,
  });
}
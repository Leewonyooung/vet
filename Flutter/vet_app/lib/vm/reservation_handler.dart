import 'dart:convert';
import 'package:get/state_manager.dart';
import 'package:vet_app/model/available_time.dart';
import 'package:vet_app/model/reservation.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:http/http.dart' as http;

class ReservationHandler extends PetHandler{
  final reservations = <Reservation>[].obs; 
  final availabletime = <AvailableTime>[].obs;

  getReservation() async{
    var url = Uri.parse('http://127.0.0.1:8000/');
    var response = await http.get(url);
    clinicSearch.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    List <Reservation> returnData = [];
  }

  getQuickReservation() async{
    var url = Uri.parse('http://127.0.0.1:8000/');
    var response = await http.get(url);
    clinicSearch.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    List <AvailableTime> returnData = [];
  }
}
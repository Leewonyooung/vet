import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vet_app/vm/image_handler.dart';

class LocationHandler extends ChatsHandler {
  double currentlat = 0;
  double currentlng = 0;
  String currentPlaceID = "";
  String clinicPlaceID = "";
  String durationText="";
  PolylinePoints polylinePoints = PolylinePoints();
  List<PointLatLng> polyline = [];
  List<LatLng> route = [];
  var lines = <Polyline>[].obs;
  // GPS 제공 동의
  checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await getCurrentLocation(); //현재 위치
    }
  }

  // 현재 위치 가져오기
  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    currentlat = position.latitude;
    currentlng = position.longitude;
  }


  //지도 경로
  //1. 현위치를 주소 id 로 가져오기
  getCurrentPlaceID() async {
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$currentlat,$currentlng&key=AIzaSyBqVdEJiq07t4uJ5ch7sk77xHK6yW0ljA0");
    var response = await http.get(url);
    if(response.statusCode == 200){
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    // print(dataConvertedJSON['results'][0]['formatted_address']); // place id
    currentPlaceID = await dataConvertedJSON['results'][0]['formatted_address'];
    }
  }

  // 2.병원 주소id 가져오기
  getClinicPlaceId(double cliniclat, double cliniclng) async {
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$cliniclat,$cliniclng&key=AIzaSyBqVdEJiq07t4uJ5ch7sk77xHK6yW0ljA0");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    clinicPlaceID = dataConvertedJSON['results'][0]['formatted_address'];
  }

  // 3. polyline
  createRoute() async {
    lines.clear();
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=$currentPlaceID&destination=$clinicPlaceID&mode=transit&key=AIzaSyBqVdEJiq07t4uJ5ch7sk77xHK6yW0ljA0");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    polyline = polylinePoints.decodePolyline(
        dataConvertedJSON['routes'][0]['overview_polyline']['points']);
        // durationText=dataConvertedJSON['routes'][0]['legs'][0]['duration']['text']; // 소요시간
        // print(dataConvertedJSON['routes'][0]['legs'][0]['distance']['text']); // 거리

    route = polyline
        .map(
          (point) => LatLng(point.latitude, point.longitude),
        )
        .toList();
    lines.add(
      Polyline(
          polylineId: const PolylineId('route'),
          points: route,
          color: Colors.red)
    );
  }

     maploading(double clinic_lat, double clinic_long)async{
      await getCurrentPlaceID();
      await getClinicPlaceId(clinic_lat, clinic_long);
      await createRoute();
      update();
    }



}

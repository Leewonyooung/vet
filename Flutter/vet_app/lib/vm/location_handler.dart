import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_app/vm/chat_handler.dart';
import 'package:http/http.dart' as http;

class LocationHandler extends ChatsHandler {
  double currentlat = 0;
  double currentlng = 0;
  String currentPlaceID = "";
  String clinicPlaceID = "";
  PolylinePoints polylinePoints = PolylinePoints();
  List<PointLatLng> polyline = [];
  List<LatLng> route = [];
  // double cliniclat=0;
  // double cliniclng=0;

  Set<Polyline> lines = {};
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
      getCurrentLocation(); //현재 위치
    }
  }

  // 현재 위치 가져오기
  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    currentlat = position.latitude;
    currentlng = position.longitude;
    // print("현위치 :$currentlat");
    // print("현위치 $currentlng");
    update();
  }

  // createRoute(double cliniclat,double cliniclng){
  //   lines.clear();
  //   lines.add(
  //     Polyline(
  //       polylineId: PolylineId('길찾기'),
  //       points: [
  //         LatLng(currentlat, currentlng),
  //         LatLng(cliniclat,cliniclng )
  //       ],
  //       color: Colors.red,
  //       width: 6
  //     ),
  //   );
  // }

  //지도 경로
  //1. 현위치를 주소 id 로 가져오기
  getCurrentPlaceID() async {
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$currentlat,$currentlng&key=AIzaSyBqVdEJiq07t4uJ5ch7sk77xHK6yW0ljA0");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    // print(dataConvertedJSON['results'][0]['formatted_address']); // place id
    currentPlaceID = dataConvertedJSON['results'][0]['formatted_address'];
    createRoute();
  }

  // 2.병원 주소id 가져오기
  getClinicPlaceId() async {
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=,&key=AIzaSyBqVdEJiq07t4uJ5ch7sk77xHK6yW0ljA0");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    clinicPlaceID = dataConvertedJSON['results'][0]['formatted_address'];
  }

  // 3. polyline
  createRoute() async {
    lines.clear();
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=$currentPlaceID&destination=%EB%8C%80%ED%95%9C%EB%AF%BC%EA%B5%AD%20%EA%B2%BD%EA%B8%B0%EB%8F%84%20%EA%B4%91%EB%AA%85%EC%8B%9C%20%EC%B2%A0%EC%82%B0%EB%8F%99%20260-3&mode=transit&key=AIzaSyBqVdEJiq07t4uJ5ch7sk77xHK6yW0ljA0");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    polyline = polylinePoints.decodePolyline(
        dataConvertedJSON['routes'][0]['overview_polyline']['points']);
    route = polyline
        .map(
          (point) => LatLng(point.latitude, point.longitude),
        )
        .toList();
    lines.add(
      Polyline(
          polylineId: const PolylineId('route'),
          points: route,
          color: Colors.red),
    );
    update();
  }
}

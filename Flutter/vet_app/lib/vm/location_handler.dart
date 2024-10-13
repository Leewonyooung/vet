import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vet_app/vm/image_handler.dart';

class LocationHandler extends ImageHandler {
  double currentlat = 0; // 현재 위치 lat
  double currentlng = 0; // 현재 위치  long
  String currentPlaceID = ""; // 길찾기에 필요한 내위치 주소 Id
  String clinicPlaceID = ""; // 찾기에 필요한 병원 주소 id
  String durationText = ""; // 소요시간
  PolylinePoints polylinePoints = PolylinePoints();
  List<PointLatLng> polyline = []; // api로 polyline decoding후 변수 저장
  List<LatLng> route = []; // 길 찾기에 필요한 체크포인트 latlong
  var lines = <Polyline>[].obs; // 길 찾기 그림
  String distanceText = "";

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
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      currentPlaceID =
          await dataConvertedJSON['results'][0]['formatted_address'];
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
        "https://maps.googleapis.com/maps/api/directions/json?origin=$currentPlaceID&destination=$clinicPlaceID&mode=transit&language=ko&key=AIzaSyBqVdEJiq07t4uJ5ch7sk77xHK6yW0ljA0");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    polyline = polylinePoints.decodePolyline(
        dataConvertedJSON['routes'][0]['overview_polyline']['points']);
    durationText=dataConvertedJSON['routes'][0]['legs'][0]['duration']['text']; // 소요시간
    distanceText=dataConvertedJSON['routes'][0]['legs'][0]['distance']['text']; // 거리

    route = polyline
        .map(
          (point) => LatLng(point.latitude, point.longitude),
        )
        .toList();
    lines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: route,
        color: Colors.red));
  }

     maploading(double clinicLat, double clinicLong)async{
      await getCurrentPlaceID();
      await getClinicPlaceId(clinicLat, clinicLong); //병원에 들어갈 place id
      await createRoute();
      update();
    }



}

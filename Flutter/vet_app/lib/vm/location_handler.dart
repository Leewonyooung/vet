import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_app/vm/image_handler.dart';

class LocationHandler extends ImageHandler{
  double currentlat=0;
  double currentlng=0;
  double cliniclat=0;
  double cliniclng=0;

  Set <Polyline> lines = {};




      // GPS 제공 동의 
      checkLocationPermission() async {
    LocationPermission permission =
        await Geolocator.checkPermission(); 
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
    update();
  }




}
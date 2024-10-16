import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vet_tab/vm/image_handler.dart';

class LocationHandler extends ImageHandler {
  Completer<GoogleMapController> mapController = Completer();
  var selectedPosition = const LatLng(0.0, 0.0).obs;
  var lat = 0.0.obs;
  var long = 0.0.obs;
  String clinicAddress = "";
  String clinicPlaceID = "";

  //Get searched location (안창빈)
  getSearchLocation(String address) async {
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=AIzaSyBqVdEJiq07t4uJ5ch7sk77xHK6yW0ljA0");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      var status = await dataConvertedJSON['status'];

      if (status == "OK") {
        String? locationType =
            await dataConvertedJSON['results'][0]['geometry']['location_type'];
        if (locationType == "ROOFTOP") {
          lat.value = await dataConvertedJSON['results'][0]['geometry']
              ['location']['lat'];
          long.value = await dataConvertedJSON['results'][0]['geometry']
              ['location']['lng'];
        } else {
          getCurrentLocation();
          errorDialogMap();
        }
      } else if (status == "ZERO_RESULTS" || status == "INVALID_REQUEST") {
        getCurrentLocation();
        errorDialogMap();
      }
    }
  }

  //Get searched location (안창빈)
  getSearchLocationFromMap(String address) async {
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=AIzaSyBqVdEJiq07t4uJ5ch7sk77xHK6yW0ljA0");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      var status = await dataConvertedJSON['status'];

      if (status == "OK") {
        String? locationType =
            await dataConvertedJSON['results'][0]['geometry']['location_type'];
        if (locationType == "ROOFTOP") {
          lat.value = await dataConvertedJSON['results'][0]['geometry']
              ['location']['lat'];
          long.value = await dataConvertedJSON['results'][0]['geometry']
              ['location']['lng'];
          updateMapCameraPro();
        } else {
          errorDialogMap();
        }
      } else if (status == "ZERO_RESULTS" || status == "INVALID_REQUEST") {
        errorDialogMap();
      }
    }
  }

  //Get address, lat, long, by longpress the googlemap (안창빈)
  longPressGoogleMap(LatLng location) async {
    selectedPosition.value = location;
    lat.value = location.latitude;
    long.value = location.longitude;
    await fetchAddressFromLatLng(location.latitude, location.longitude);
  }

  // get the longpressed loaction address by using lat and long extracted from longpressGoogleMap function
  fetchAddressFromLatLng(double lat, double long) async {
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&language=ko&key=AIzaSyBqVdEJiq07t4uJ5ch7sk77xHK6yW0ljA0");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    clinicAddress = dataConvertedJSON['results'][0]['formatted_address'];
  }

  // error dialog when user did not enter appropriate address (안창빈)
  errorDialogMap() async {
    await Get.defaultDialog(
      title: 'error',
      content: const Text('검색가능한 결과가 없습니다 주소를 정확하게 작성해주세요'),
      textCancel: 'cancel',
      barrierDismissible: true,
    );
  }

  // GPS permission (안창빈)
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

  // Get current map location(안창빈)
  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    lat.value = position.latitude;
    long.value = position.longitude;
  }

  // update map camera programmatically (안창빈)
  updateMapCameraPro() async {
    if (mapController.isCompleted) {
      final GoogleMapController controller = await mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat.value, long.value),
        zoom: 18,
      )));
    } else {}
  }

  //updateAddress from clinic_map to clinic_add (안창빈)
  updateAddress(String updateAddress) {
    clinicAddress = updateAddress;
  }
}

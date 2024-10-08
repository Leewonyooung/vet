import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_app/vm/vm_handler.dart';

class ClinicLocation extends StatelessWidget {
  const ClinicLocation({super.key});

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> mapController =
        Completer<GoogleMapController>();
    VmHandler vmHandler = Get.put(VmHandler());
    final value = Get.arguments ?? "__"; // 0:이름, 1:병원위도, 2:병원경도, 3:병원 도로명 주소
    vmHandler.checkLocationPermission();
    vmHandler.getCurrentPlaceID();
    return Scaffold(
        appBar: AppBar(
          title: const Text('위치보기'),
        ),
        body: GetBuilder<VmHandler>(builder: (controller) {
          if (controller.currentlat == 0 || controller.currentlng == 0) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Center(
              child: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: CameraPosition(
                    zoom: 15,
                    target:
                        LatLng(controller.currentlat, controller.currentlng),
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    mapController.complete(controller);
                  },
                  markers: {
                    Marker(
                        icon: BitmapDescriptor.defaultMarker,
                        infoWindow: InfoWindow(
                            title: value[0], snippet: value[0]), //병원 이름 표시
                        markerId: MarkerId(value[0]),
                        position: LatLng(value[1], value[2])),
                    Marker(
                      markerId: const MarkerId('병원'),
                      position:
                          LatLng(controller.currentlat, controller.currentlng),
                    ),
                  },
                  polylines: vmHandler.lines),
            );
          }
        }));
  }

  ///fff
}

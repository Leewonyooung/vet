import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_app/vm/vm_handler.dart';

class ClinicLocation extends StatelessWidget {
  const  ClinicLocation({super.key});
    
  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
    VmHandler vmHandler = Get.put(VmHandler());
    final value = Get.arguments ?? "__";
    vmHandler.checkLocationPermission();
    return Scaffold(
        appBar: AppBar(
          title: const Text('위치보기'),
        ),
        body: GetBuilder<VmHandler>(
          builder: (controller) {
            return Center(
              child: controller.currentlat==0 || controller.currentlng == 0? CircularProgressIndicator() : 
                GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: CameraPosition(
                        zoom: 15,
                          target: LatLng(
                              controller.currentlat,controller.currentlng
                              ),
                      ),
                      onMapCreated: (GoogleMapController controller){
                        mapController.complete(controller);
                      },
                      markers: {
                        Marker(
                          icon: BitmapDescriptor.defaultMarker,
                          markerId: MarkerId(value[0]),
                          position: LatLng(value[1], value[2])
                          ),
                          Marker(
                            markerId: MarkerId('현위치'),
                            position: LatLng(controller.currentlat, controller.currentlng),
                            ),
                          },
                          polylines: controller.lines.toSet(),
              ),
            );
          },
        ));
  }

  ///fff
}

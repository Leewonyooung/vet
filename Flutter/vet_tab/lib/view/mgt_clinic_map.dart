import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_tab/vm/clinic_handler.dart';
import 'package:vet_tab/vm/location_handler.dart';

class MgtClinicMap extends StatelessWidget {
  MgtClinicMap({super.key});

  @override
  Widget build(BuildContext context) {
    final clinicHandler = Get.put(ClinicHandler());
    final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
    final String value = Get.arguments ?? "__"; 

    // 0=병원id

    return Scaffold(
      body: FutureBuilder(
      future: clinicHandler.checkLocationPermission(),
      builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('오류 발생: ${snapshot.error}'),
              );
            } else {
        return GetBuilder<ClinicHandler>(
          builder: (controller) {
            print(value);
            clinicHandler.clinicAddressSearch(value);
            print(clinicHandler.lat);
            print(clinicHandler.long);
            return GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: CameraPosition(
                target: LatLng(clinicHandler.lat, clinicHandler.long),
                zoom: 13
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController.complete(controller);
              },
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
            );
          },
        );        
            }
      },
      ),
    );
  }
}/// END

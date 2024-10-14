import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_tab/vm/clinic_handler.dart';

class MgtClinicMap extends StatelessWidget {
  const MgtClinicMap({super.key});

  @override
  Widget build(BuildContext context) {
    final clinicHandler = Get.put(ClinicHandler());
    final String loctionvalue = Get.arguments ?? "empty";
    final TextEditingController searchController = TextEditingController();

    // 0=병원id

    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 찾기'),
      ),
      body: FutureBuilder(
        future: clinicHandler.getSearchLocation(loctionvalue),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('오류 발생: ${snapshot.error}'),
            );
          } else {
            return GetBuilder<ClinicHandler>(
              builder: (_) {
                // print(value);
                // clinicHandler.getSearchLocation(value);
                searchController.text = loctionvalue;
                return Obx(
                  () {
                    return Stack(alignment: Alignment.bottomCenter, children: [
                      GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(clinicHandler.lat.value,
                                clinicHandler.long.value),
                            zoom: 18),
                        onMapCreated: (GoogleMapController controller) {
                          if (!clinicHandler.mapController.isCompleted) {
                            clinicHandler.mapController.complete(controller);
                          }
                        },
                        markers: {
                          Marker(
                              icon: BitmapDescriptor.defaultMarker,
                              markerId: const MarkerId("selected"),
                              position: LatLng(clinicHandler.lat.value,
                                  clinicHandler.long.value)),
                        },
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        zoomControlsEnabled: true,
                        zoomGesturesEnabled: true,
                        onLongPress: (LatLng position) async {
                          await clinicHandler.longPressGoogleMap(position);
                          searchController.text = clinicHandler.clinicAddress;
                        },
                      ),
                      Positioned(
                          top: MediaQuery.sizeOf(context).height * 0.1,
                          child: SizedBox(
                            width: 400,
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      clinicHandler.updateAddress(searchController.text);
                                      clinicHandler.getSearchLocationFromMap(
                                          searchController.text);
                                    },
                                    icon: const Icon(Icons.search)),
                              ),
                            ),
                          )),
                      Positioned(
                          bottom: MediaQuery.sizeOf(context).height * 0.1,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black
                            ),
                            onPressed: () {
                              clinicHandler.mapController = Completer();
                              Get.back(
                                result: {
                                  'address' : clinicHandler.clinicAddress,
                                  'lat' : clinicHandler.lat.value,
                                  'long' : clinicHandler.long.value,
                                }
                              );
                            }, 
                            child: const Text("주소 확정"),
                            ),
                          ),
                    ]);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}/// END

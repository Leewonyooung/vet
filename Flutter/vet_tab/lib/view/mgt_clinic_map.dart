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
    final String locationValue = Get.arguments ?? "empty";
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '주소 찾기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
      ),
      body: FutureBuilder(
        future: clinicHandler.getSearchLocation(locationValue),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '오류 발생: ${snapshot.error}',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          } else {
            return GetBuilder<ClinicHandler>(
              builder: (_) {
                searchController.text = locationValue;
                return Obx(
                  () {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(clinicHandler.lat.value,
                                clinicHandler.long.value),
                            zoom: 18,
                          ),
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
                                  clinicHandler.long.value),
                            ),
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
                          top: 20,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                labelText: '주소를 입력하세요',
                                border: InputBorder.none,
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    clinicHandler
                                        .updateAddress(searchController.text);
                                    clinicHandler.getSearchLocationFromMap(
                                        searchController.text);
                                  },
                                  icon: const Icon(Icons.search),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              clinicHandler.mapController = Completer();
                              Get.back(result: {
                                'address': clinicHandler.clinicAddress,
                                'lat': clinicHandler.lat.value,
                                'long': clinicHandler.long.value,
                              });
                            },
                            child: const Text(
                              "주소 확정",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

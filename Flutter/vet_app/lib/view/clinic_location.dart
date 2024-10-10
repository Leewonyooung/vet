import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_app/vm/clinic_handler.dart';

class ClinicLocation extends StatelessWidget {
  const ClinicLocation({super.key});

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> mapController =
        Completer<GoogleMapController>();
    VmHandler vmHandler = Get.put(VmHandler());
    final value = Get.arguments ?? "__"; 
    vmHandler.checkLocationPermission();
    vmHandler.getClinicDetail(value[0]);
    final result = vmHandler.clinicDetail[0];

    // 0=병원id

    return Scaffold(
        appBar: AppBar(
          title: const Text('위치보기'),
        ),
        body: FutureBuilder(
          future: vmHandler.maploading(result.latitude, result.longitude),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('오류 발생: ${snapshot.error}'),
              );
            } else {
              return GetBuilder<VmHandler>(builder: (controller) {
                if (vmHandler.lines.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      GoogleMap(
                        mapType: MapType.hybrid,
                        initialCameraPosition: CameraPosition(
                          zoom: 15,
                          target: LatLng(
                              controller.currentlat, controller.currentlng),
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          mapController.complete(controller);
                        },
                        markers: {
                          Marker(
                              icon: BitmapDescriptor.defaultMarker,
                              infoWindow: InfoWindow(
                                  title: result.name,
                                  snippet: result.name), //병원 이름 표시
                              markerId: MarkerId(result.name),
                              position: LatLng(result.latitude, result.longitude)),
                          Marker(
                            markerId: const MarkerId('병원'),
                            position: LatLng(
                                controller.currentlat, controller.currentlng),
                          ),
                        },
                        polylines: vmHandler.lines.toSet(),
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        zoomControlsEnabled: true,
                        zoomGesturesEnabled: true,
                      ),
                      Positioned(
                        bottom: MediaQuery.sizeOf(context).height * 0.1,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Card(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.network(
                                        'http://127.0.0.1:8000/clinic/view/${result.image}',
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8*0.35,
                                                height:  MediaQuery.of(context).size.height *
                                                0.1
                                                ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(result.name,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          ), 
                                          //병원 끝나는시간
                                          Text("${result.endTime} 영업종료"), 
                                          Text(vmHandler.durationText)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width:  MediaQuery.of(context).size.width * 0.8,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.yellowAccent
                                    ),
                                      onPressed: () {
                                        //예약하기
                                      }, 
                                      child: const Text('예약하기')),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              });
            }
          },
        ));

    // /fff
  }
}

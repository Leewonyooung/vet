import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_app/view/login.dart';
import 'package:vet_app/view/make_reservation.dart';
import 'package:vet_app/vm/favorite_handler.dart';
import 'package:vet_app/vm/reservation_handler.dart';

class ClinicLocation extends StatelessWidget {
  ClinicLocation({super.key});

  final FavoriteHandler vmHandler = Get.find();
  final ReservationHandler reservationHandler = Get.find();

  @override
  build(BuildContext context) {
    final Completer<GoogleMapController> mapController =
        Completer<GoogleMapController>();
    final result = vmHandler.clinicDetail[0];

    // 0=병원id

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            '위치보기',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green.shade400,
          elevation: 0,
        ),
        body: FutureBuilder(
          future: vmHandler.maploading(result.latitude, result.longitude),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('다시 시도하세요', style: TextStyle(fontSize: 18)),
              );
            } else {
              return GetBuilder<FavoriteHandler>(builder: (_) {
                if (vmHandler.lines.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      GoogleMap(
                        mapType: MapType.terrain,
                        initialCameraPosition: CameraPosition(
                          zoom: 15,
                          target: LatLng(
                              vmHandler.currentlat, vmHandler.currentlng),
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
                              position:
                                  LatLng(result.latitude, result.longitude)),
                          Marker(
                            markerId: const MarkerId('병원'),
                            position: LatLng(
                                vmHandler.currentlat, vmHandler.currentlng),
                          ),
                        },
                        polylines: vmHandler.lines.toSet(),
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        zoomControlsEnabled: true,
                        zoomGesturesEnabled: true,
                      ),
                      Positioned(
                        bottom: MediaQuery.sizeOf(context).height * 0.02,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  '대중교통 정보만 지원합니다.',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        'http://127.0.0.1:8000/clinic/view/${result.image}',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            result.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            vmHandler.workText.value,
                                            style: TextStyle(
                                              color: vmHandler.workColor.value,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "${result.endTime} 영업종료",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            "거리 : ${vmHandler.distanceText}",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Visibility(
                                visible:
                                    reservationHandler.resButtonValue.value,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber.shade300,
                                      foregroundColor: Colors.black,
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (vmHandler.isLoggedIn() == false) {
                                        Get.to(() => Login());
                                      } else {
                                        Get.to(() => MakeReservation(),
                                            arguments: [
                                              reservationHandler
                                                  .canReservationClinic[0].id,
                                              reservationHandler
                                                  .canReservationClinic[0].name,
                                              reservationHandler
                                                  .canReservationClinic[0]
                                                  .latitude,
                                              reservationHandler
                                                  .canReservationClinic[0]
                                                  .longitude,
                                              reservationHandler
                                                  .canReservationClinic[0].time,
                                              reservationHandler
                                                  .canReservationClinic[0]
                                                  .address,
                                            ]);
                                      }
                                    },
                                    child: const Text('예약하기',
                                        style: TextStyle(fontSize: 16)),
                                  ),
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

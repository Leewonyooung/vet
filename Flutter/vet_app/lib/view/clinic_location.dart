import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final Completer<GoogleMapController> mapController =
        Completer<GoogleMapController>();
    final result = vmHandler.clinicDetail[0];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '위치보기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: screenWidth * 0.05,
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
            return Center(
              child: Text(
                '다시 시도하세요',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                ),
              ),
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
                        target:
                            LatLng(vmHandler.currentlat, vmHandler.currentlng),
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        mapController.complete(controller);
                      },
                      markers: {
                        Marker(
                          icon: BitmapDescriptor.defaultMarker,
                          infoWindow: InfoWindow(
                            title: result.name,
                            snippet: result.name,
                          ),
                          markerId: MarkerId(result.name),
                          position: LatLng(result.latitude, result.longitude),
                        ),
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
                      bottom: screenHeight * 0.02,
                      child: Container(
                        width: screenWidth * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.03),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.5),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: Text(
                                '대중교통 정보만 지원합니다.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.03),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "http://127.0.0.1:8000/clinic/view/${result.image}",
                                      imageBuilder: (context, imageProvider) =>
                                          CircleAvatar(
                                        radius: screenWidth * 0.08,
                                        backgroundImage: imageProvider,
                                      ),
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          result.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.045,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: screenWidth * 0.02),
                                        Text(
                                          vmHandler.workText.value,
                                          style: TextStyle(
                                            color: vmHandler.workColor.value,
                                            fontSize: screenWidth * 0.04,
                                          ),
                                        ),
                                        Text(
                                          "${result.endTime} 영업종료",
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                          ),
                                        ),
                                        Text(
                                          "거리 : ${vmHandler.distanceText}",
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Visibility(
                              visible: reservationHandler.resButtonValue.value,
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber.shade300,
                                    foregroundColor: Colors.black,
                                    minimumSize: Size(
                                        double.infinity, screenWidth * 0.12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.03),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (!vmHandler.isLoggedIn()) {
                                      Get.to(() => Login());
                                    } else {
                                      Get.to(
                                        () => MakeReservation(),
                                        arguments: [
                                          reservationHandler
                                              .canReservationClinic[0].id,
                                          reservationHandler
                                              .canReservationClinic[0].name,
                                          reservationHandler
                                              .canReservationClinic[0].latitude,
                                          reservationHandler
                                              .canReservationClinic[0]
                                              .longitude,
                                          reservationHandler
                                              .canReservationClinic[0].time,
                                          reservationHandler
                                              .canReservationClinic[0].address,
                                        ],
                                      );
                                    }
                                  },
                                  child: Text(
                                    '예약하기',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
      ),
    );
  }
}

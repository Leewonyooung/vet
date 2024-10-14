import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_app/view/navigation.dart';
import 'package:vet_app/view/query_reservation.dart';

// 예약완료 페이지
class ReservationComplete extends StatelessWidget {
  ReservationComplete({super.key});
  final makervalue = Get.arguments; // 예약할 때 필요한 병원정보 받아옴

  @override
  Widget build(BuildContext context) {
    final queryvalue = Get.arguments;
    var value;
    makervalue == null ? value = queryvalue : value = makervalue;
    final Completer<GoogleMapController> mapController = // 구글지도 맵
        Completer<GoogleMapController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              '예약 확정',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("감사합니다\n 고객님\n${value[1]}의 예약이\n확정되셨습니다."),
            Row(
              children: [
                const Icon(Icons.arrow_forward),
                Text(' 일정 : ${value[4]}')
              ],
            ),
            const Text(
              '찾아오시는길',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(' * 주소: ${value[5]}'),
            SizedBox(
              width: 300,
              height: 200,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  zoom: 15,
                  target: LatLng(value[2], value[3]),
                ),
                onMapCreated: (GoogleMapController controller) {
                  mapController.complete(controller);
                },
                markers: {
                  Marker(
                      icon: BitmapDescriptor.defaultMarker,
                      infoWindow: InfoWindow(
                          title: value[1], snippet: value[1]), //병원 이름 표시
                      markerId: MarkerId(value[1]),
                      position: LatLng(value[2], value[3])),
                  Marker(
                    markerId: const MarkerId('병원'),
                    position: LatLng(value[2], value[3]),
                  ),
                },
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: false,
                rotateGesturesEnabled: false,
                buildingsEnabled: false,
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => Get.to(() => QueryReservation()),
                  child: const Text('예약내역'),
                ),
                ElevatedButton(
                  onPressed: () => Get.to(Navigation()),
                  child: const Text('홈으로'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

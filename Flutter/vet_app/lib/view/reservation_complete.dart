import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_app/view/navigation.dart';
import 'package:vet_app/view/query_reservation.dart';
import 'package:vet_app/vm/reservation_handler.dart';

// 예약완료 페이지
class ReservationComplete extends StatelessWidget {
  final ReservationHandler vmHandler = Get.find();
  ReservationComplete({super.key});
  final makervalue = Get.arguments; // 예약할 때 필요한 병원정보 받아옴

  @override
  Widget build(BuildContext context) {
    final queryvalue = Get.arguments;
    var value = makervalue == null
        ? queryvalue
        : makervalue ??
            [
              ' ',
              ' ',
              ' ',
              ' ',
              ' ',
              ' ',
              ' ',
            ];
    final Completer<GoogleMapController> mapController = // 구글지도 맵
        Completer<GoogleMapController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '예약 확정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: Colors.green.shade400,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "예약이 확정되었습니다",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoCard(value),
              const SizedBox(height: 30),
              const Text(
                '찾아오시는 길',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                ' * 주소: ${value[5]}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              _buildMap(value, mapController),
              const SizedBox(height: 30),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  _buildInfoCard(List<dynamic> value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${value[1]}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.green),
                const SizedBox(width: 10),
                Text('일정: ${value[4]}', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildMap(List<dynamic> value, Completer<GoogleMapController> mapController) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
              infoWindow: InfoWindow(title: value[1], snippet: value[1]),
              markerId: MarkerId(value[1]),
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
    );
  }

  _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.list),
          label: const Text('예약내역'),
          onPressed: () => Get.to(() => QueryReservation()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.home),
          label: const Text('홈으로'),
          onPressed: () => Get.to(() => Navigation()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

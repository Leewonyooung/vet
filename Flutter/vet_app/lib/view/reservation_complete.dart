import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vet_app/view/navigation.dart';
import 'package:vet_app/vm/reservation_handler.dart';

// 예약 완료 페이지
class ReservationComplete extends StatelessWidget {
  final ReservationHandler vmHandler = Get.find();
  ReservationComplete({super.key});
  final List<dynamic> makervalue = Get.arguments ?? [];

  @override
  Widget build(BuildContext context) {
    final List<dynamic> queryvalue = Get.arguments ?? [];
    final List<dynamic> value = makervalue.isNotEmpty
        ? makervalue
        : queryvalue.isNotEmpty
            ? queryvalue
            : [' ', ' ', ' ', ' ', ' ', ' '];

    final Completer<GoogleMapController> mapController = Completer();

    final screenWidth = MediaQuery.of(context).size.width;

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
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Icon(
                  Icons.check_circle_outline,
                  size: screenWidth * 0.2,
                  color: Colors.green.shade400,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "예약이 확정되었습니다",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoCard(value, screenWidth),
              const SizedBox(height: 30),
              Text(
                '찾아오시는 길',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ' * 주소: ${value[5]}',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              const SizedBox(height: 20),
              _buildMap(value, mapController, screenWidth),
              const SizedBox(height: 30),
              _buildButtons(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<dynamic> value, double screenWidth) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${value[1]}",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                Text(
                  '일정: ${value[4]}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(List<dynamic> value,
      Completer<GoogleMapController> mapController, double screenWidth) {
    return Container(
      height: screenWidth * 0.6,
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
              infoWindow: InfoWindow(
                title: value[1],
                snippet: value[1],
              ),
              markerId: MarkerId(value[1]),
              position: LatLng(value[2], value[3]),
            ),
          },
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
        ),
      ),
    );
  }

  Widget _buildButtons(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.home),
          label: const Text('홈으로'),
          onPressed: () => Get.to(() => Navigation()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade400,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.1,
              vertical: screenWidth * 0.04,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

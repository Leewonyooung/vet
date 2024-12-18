import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/make_reservation.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/reservation_handler.dart';

// 긴급 예약 페이지
class Reservation extends StatelessWidget {
  Reservation({super.key});

  final ReservationHandler vmHandler = Get.put(ReservationHandler());
  final PetHandler petHandler = Get.put(PetHandler());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '긴급 예약',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: GetBuilder<ReservationHandler>(builder: (_) {
        return FutureBuilder(
          future: vmHandler.getQuickReservation(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildErrorState(screenWidth);
            } else {
              return Obx(() {
                if (vmHandler.availableclinic.isEmpty) {
                  return _buildErrorState(screenWidth);
                }
                return _buildClinicList(screenWidth);
              });
            }
          },
        );
      }),
    );
  }

  // 에러 상태 위젯
  Widget _buildErrorState(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: screenWidth * 0.15,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '예약가능한 병원이 없습니다.',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 병원 리스트 빌더
  Widget _buildClinicList(double screenWidth) {
    return ListView.builder(
      itemCount: vmHandler.availableclinic.length,
      itemBuilder: (context, index) {
        final clinic = vmHandler.availableclinic[index];
        return Card(
          color: Colors.white,
          elevation: 4,
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.02,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () async {
              await petHandler.makeBorderlist();
              Get.to(() => MakeReservation(), arguments: [
                clinic.id,
                clinic.name,
                clinic.latitude,
                clinic.longitude,
                clinic.time,
                clinic.address,
              ]);
            },
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildClinicImage(clinic.image, screenWidth),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clinic.name,
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          clinic.address,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '예약 가능 시간: ${clinic.time}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: screenWidth * 0.05,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 병원 이미지 빌더
  Widget _buildClinicImage(String imageUrl, double screenWidth) {
    return CachedNetworkImage(
      imageUrl: "http://127.0.0.1:8000/available/view/$imageUrl",
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: screenWidth * 0.12,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: screenWidth * 0.12,
        child: const CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: screenWidth * 0.12,
        child: const Icon(Icons.error),
      ),
    );
  }
}

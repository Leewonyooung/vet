import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/reservation_complete.dart';
import 'package:vet_app/vm/reservation_handler.dart';

class QueryReservation extends StatelessWidget {
  QueryReservation({super.key});

  final ReservationHandler vmHandler = Get.put(ReservationHandler());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '예약 내역',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: Obx(() {
        final reservations = vmHandler.searchreservation;
        if (reservations.isEmpty) {
          return _buildEmptyState(screenWidth);
        }

        return ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final clinic = reservations[index];
            return _buildReservationCard(context, clinic, screenWidth);
          },
        );
      }),
    );
  }

  // 예약 내역이 없는 경우 화면
  Widget _buildEmptyState(double screenWidth) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: screenWidth * 0.2,
              color: Colors.grey[400],
            ),
            SizedBox(height: screenWidth * 0.05),
            const Text(
              '예약 내역이 없습니다.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 예약 카드 생성
  Widget _buildReservationCard(
    BuildContext context,
    dynamic clinic,
    double screenWidth,
  ) {
    return GestureDetector(
      onTap: () {
        Get.offAll(
          ReservationComplete(),
          arguments: [
            clinic.clinicId,
            clinic.clinicName,
            clinic.latitude,
            clinic.longitude,
            clinic.time,
            clinic.address,
          ],
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: screenWidth * 0.04),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(screenWidth * 0.04),
            leading: CircleAvatar(
              radius: screenWidth * 0.08,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.event,
                size: screenWidth * 0.07,
                color: Colors.blue.shade700,
              ),
            ),
            title: Text(
              clinic.clinicName,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: screenWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '예약 시간: ${clinic.time}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    '주소: ${clinic.address}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            trailing: Chip(
              label: const Text('예약완료'),
              backgroundColor: Colors.green.shade100,
              labelStyle: TextStyle(
                color: Colors.green.shade700,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

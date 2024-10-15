import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/reservation_complete.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/reservation_handler.dart';

class QueryReservation extends StatelessWidget {
  QueryReservation({super.key});

  final ReservationHandler vmHnadler = Get.find();

  @override
  Widget build(BuildContext context) {
    final LoginHandler loginHandler = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '예약 내역',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GetBuilder<ReservationHandler>(
        builder: (_) {
          return FutureBuilder(
            future: vmHnadler.getReservation(loginHandler.getStoredEmail()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '예약한 병원이 없습니다.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Obx(
                  () {
                    return ListView.builder(
                      itemCount: vmHnadler.searchreservation.length,
                      itemBuilder: (context, index) {
                        final clinic = vmHnadler.searchreservation[index];
                        return GestureDetector(
                          onTap: () {
                            Get.offAll(ReservationComplete(), arguments: [
                              clinic.clinicId,
                              clinic.clinicName,
                              clinic.latitude,
                              clinic.longitude,
                              clinic.time,
                              clinic.address
                            ]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Icon(
                                    Icons.event,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                title: Text(
                                  clinic.clinicName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      '예약 시간: ${clinic.time}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '주소: ${clinic.address}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Chip(
                                  label: const Text('예약완료'),
                                  backgroundColor: Colors.green.shade100,
                                  labelStyle: TextStyle(
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

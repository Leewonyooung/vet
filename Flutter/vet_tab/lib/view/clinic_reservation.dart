import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_tab/vm/reservation_handler.dart';

class ClinicReservation extends StatelessWidget {
  ClinicReservation({super.key});
  final vmHandler = Get.put(ReservationHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: GetBuilder<ReservationHandler>(
        builder: (_) {
          return FutureBuilder(
            future: vmHandler.currentReservationClinic(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError ||
                  vmHandler.clinicreservations.isEmpty) {
                // 예약 내역이 없는 경우
                return const Center(
                  child: Text(
                    '예약 내역이 없습니다.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                );
              } else {
                // 예약 내역이 있는 경우
                return Obx(
                  () {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 제목 행
                            Container(
                              color: Colors.blueGrey[50],
                              padding: const EdgeInsets.all(8.0),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _HeaderCell('환자 이름'),
                                  _HeaderCell('동물 종류'),
                                  _HeaderCell('동물 카테고리'),
                                  _HeaderCell('특징'),
                                  _HeaderCell('증상'),
                                  _HeaderCell('예약 시간'),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 1,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(height: 10),
                            // 데이터 리스트
                            Expanded(
                              child: ListView.builder(
                                itemCount: vmHandler.clinicreservations.length,
                                itemBuilder: (context, index) {
                                  final clinic =
                                      vmHandler.clinicreservations[index];
                                  return Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoCell(clinic.userName),
                                          _buildInfoCell(clinic.petType),
                                          _buildInfoCell(clinic.petCategory),
                                          _buildInfoCell(clinic.petFeatures),
                                          _buildInfoCell(clinic.symptoms),
                                          _buildInfoCell(clinic.time),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildInfoCell(String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String title;
  const _HeaderCell(this.title);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}

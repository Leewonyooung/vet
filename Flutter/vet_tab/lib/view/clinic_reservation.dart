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
      // appBar: AppBar(
      //   title: const Text(
      //     'Chat Room',
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   backgroundColor: Colors.blueGrey,
      //   foregroundColor: Colors.white,
      //   automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      // ),
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
                        padding: const EdgeInsets.only(top: 20.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: MediaQuery.of(context).size.height / 1.4,
                          child: ListView.builder(
                            itemCount: vmHandler.clinicreservations.length,
                            itemBuilder: (context, index) {
                              final clinic =
                                  vmHandler.clinicreservations[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12.0),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoColumn(
                                          '환자 이름', clinic.userName),
                                      _buildInfoColumn('동물 종류', clinic.petType),
                                      _buildInfoColumn(
                                          '동물 카테고리', clinic.petCategory),
                                      _buildInfoColumn(
                                          '특징', clinic.petFeatures),
                                      _buildInfoColumn('증상', clinic.symptoms),
                                      _buildInfoColumn('예약 시간', clinic.time),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

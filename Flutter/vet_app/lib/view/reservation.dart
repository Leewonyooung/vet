import 'package:flutter/material.dart';
import 'package:vet_app/view/make_reservation.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/reservation_handler.dart';
import 'package:get/get.dart';

// 긴급 예약 페이지
class Reservation extends StatelessWidget {
  Reservation({super.key});

  final vmHnadler = Get.put(ReservationHandler());
  final petHandler = Get.put(PetHandler());

  @override
  Widget build(BuildContext context) {
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
            future: vmHnadler.getQuickReservation(),
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
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '예약가능한 병원이 없습니다.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Obx(() {
                  return ListView.builder(
                      itemCount: vmHnadler.availableclinic.length,
                      itemBuilder: (context, index) {
                        final clinic = vmHnadler.availableclinic[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                                clinic.address
                              ]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      'http://127.0.1:8000/available/view/${clinic.image}',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          clinic.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          clinic.address,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '예약 가능 시간: ${clinic.time}',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                });
              }
            });
      }),
    );
  }
}

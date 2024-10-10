import 'package:flutter/material.dart';
import 'package:vet_app/view/query_reservation.dart';
import 'package:vet_app/vm/reservation_handler.dart';
import 'package:get/get.dart';

class Reservation extends StatelessWidget {
  Reservation({super.key});

  final vmHnadler = Get.put(ReservationHandler());

  @override
  Widget build(BuildContext context) {
    final vmHnadler = Get.put(ReservationHandler());

    return Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [Icon(Icons.local_hospital), Text('긴급예약')],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  // 즐겨찾기
                },
                icon: const Icon(Icons.favorite_border_outlined)),
            IconButton(
                onPressed: () {
                  // 내정보
                },
                icon: const Icon(Icons.account_circle_outlined)),
          ],
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
                    child: Text('Error : ${snapshot.error}'),
                  );
                } else {
                  return Obx(() {
                    return ListView.builder(
                        itemCount: vmHnadler.availableclinic.length,
                        itemBuilder: (context, index) {
                          final clinic = vmHnadler.availableclinic[index];
                          return Card(
                            child: Row(
                              children: [
                                Image.network (
                                  'http://127.0.1:8000/view/${clinic.image}',
                                  width: 100,
                                  height: 80,),
                                Text('  ${clinic.name}'),
                                // Text('  ${clinic.address}'),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => const QueryReservation(), arguments: [
                                      clinic.name,
                                      clinic.latitude,
                                      clinic.longitude,
                                      clinic.image,
                                      clinic.time
                                    ]);
                                  },
                                  child: const Icon(
                                      Icons.arrow_circle_right_outlined),
                                ),
                              ],
                            ),
                          );
                        });
                  });
                }
              });
        }));
  }
}

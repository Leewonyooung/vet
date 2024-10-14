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
          title: const Row(
            children: [Icon(Icons.local_hospital), Text('긴급예약')],
          ),
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
                  return const Center(
                    child: Text('예약가능한 병원이 없습니다.'),
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
                                SizedBox(
                                  width: 100,
                                  height: 80,
                                  child: Image.network(
                                    'http://127.0.1:8000/available/view/${clinic.image}',
                                  ),
                                ),
                                SizedBox(
                                  width: 220,
                                  height: 80,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(' ${clinic.name}'),
                                    ],
                                  )),
                                ElevatedButton(
                                  onPressed: () async{
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

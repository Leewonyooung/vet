import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_tab/vm/reservation_handler.dart';

class ClinicReservation extends StatelessWidget {
  ClinicReservation({super.key});
  final vmHnadler = Get.put(ReservationHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ReservationHandler>(
        builder: (_) {
          return FutureBuilder(
            future: vmHnadler.currentReservationClinic(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('예약내역이 없습니다.'),
                );
              } else {
                return Obx(
                  () {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.3,
                              height: MediaQuery.of(context).size.height / 1.6,
                              child: ListView.builder(
                                itemCount: vmHnadler.clinicreservations.length,
                                itemBuilder: (context, index) {
                                  final clinic =
                                      vmHnadler.clinicreservations[index];
                                  return Column(
                                    children: [
                                      Column(
                                        children: [
                                          Row(children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                width: 150,
                                                height: 40,
                                                child: Text(
                                                  '  ${clinic.userName}',
                                                  style: const TextStyle(
                                                      fontSize: 30),
                                                )),
                                            Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                width: 150,
                                                height: 40,
                                                child: Text(
                                                  '  ${clinic.petType}',
                                                  style: const TextStyle(
                                                      fontSize: 30),
                                                )),
                                            Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                width: 150,
                                                height: 40,
                                                child: Text(
                                                  ' ${clinic.petCategory}',
                                                  style: const TextStyle(
                                                      fontSize: 30),
                                                )),
                                            Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                width: 150,
                                                height: 40,
                                                child: Text(
                                                  '  ${clinic.petFeatures}',
                                                  style: const TextStyle(
                                                      fontSize: 30),
                                                )),
                                            Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                width: 150,
                                                height: 40,
                                                child: Text(
                                                  '  ${clinic.symptoms}',
                                                  style: const TextStyle(
                                                      fontSize: 30),
                                                )),
                                            Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                width: 250,
                                                height: 40,
                                                child: Text(
                                                  '  ${clinic.time}',
                                                  style: const TextStyle(
                                                      fontSize: 30),
                                                )),
                                          ]),
                                        ],
                                      ),
                                    ],
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
}

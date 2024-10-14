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
                }else{
                  return Obx(() {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Text('예약자'),
                            Text('종류'),
                            Text('품종'),
                            Text('증상'),
                            Text('예약시간')
                          ],
                        ),
                        ListView.builder(
                          itemCount: vmHnadler.clinicreservations.length,
                          itemBuilder: (context, index) {
                            final clinic = vmHnadler.clinicreservations[index];
                            return Card(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                          ),
                      ],
                    );
                  },);
                }
            },);
        },),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/reservation_complete.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/reservation_handler.dart';

class QueryReservation extends StatelessWidget {
  QueryReservation({super.key});
  final vmHnadler = Get.put(ReservationHandler());

  @override
  Widget build(BuildContext context) {
    final LoginHandler loginHandler = Get.put(LoginHandler());
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약내역'),
      ),
      body: GetBuilder<ReservationHandler>(builder: (_) {
        return FutureBuilder(
          future: vmHnadler.getReservation(loginHandler.getStoredEmail()), 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('예약한 병원이 없습니다.'),
                  );
                } else{
                  return Obx(() {
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
                          child: Card(
                            child: Column(
                              children: [
                                const Text('예약완료', style: TextStyle(
                                  fontSize: 12
                                ),),
                                Text(clinic.time),
                                Text(clinic.clinicName)
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },);
                }
            },
        );
      },),
    );
  }
}

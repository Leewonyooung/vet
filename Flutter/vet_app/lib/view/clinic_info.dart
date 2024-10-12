import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/chat_view.dart';
import 'package:vet_app/view/clinic_location.dart';
import 'package:vet_app/view/login.dart';
import 'package:vet_app/view/make_reservation.dart';
import 'package:vet_app/vm/favorite_handler.dart';
import 'package:vet_app/vm/reservation_handler.dart';

class ClinicInfo extends StatelessWidget {
  ClinicInfo({super.key});
  final FavoriteHandler vmHandler = Get.find();
  final ChatsHandler chatsHandler = Get.find();
  @override
  Widget build(BuildContext context) {
    FavoriteHandler favoriteHandler = Get.put(FavoriteHandler());
    ReservationHandler reservationHandler = Get.put(ReservationHandler());
    var value = Get.arguments ?? "__"; // clinicid = value
    favoriteHandler.searchFavoriteClinic(vmHandler.getStoredEmail(), value[0]);
    reservationHandler.reservationButtonMgt(value[0]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 결과'),
      ),
      body: GetBuilder<FavoriteHandler>(
        builder: (_) {
          return FutureBuilder(
              future: vmHandler.getClinicDetail(value[0]),
              builder: (context, snapshot) {
                final result = vmHandler.clinicDetail;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error:${snapshot.error}'));
                } else {
                  return Obx(() {
                    return Center(
                      child: Column(
                        children: [
                          Text(
                            result[0].name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: (MediaQuery.of(context).size.width) * 0.7,
                            height: MediaQuery.of(context).size.height * 0.35,
                            child: Card(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      'http://127.0.0.1:8000/clinic/view/${result[0].image}',
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4 *
                                              0.7,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 지도 보는 버튼
                                        IconButton(
                                            onPressed: () => Get.to(
                                                () => ClinicLocation(),
                                                arguments: [result[0].id]),
                                            icon: const Icon(
                                                Icons.pin_drop_outlined)),

                                        // 즐겨찾기 등록 버튼
                                      IconButton(
                                        onPressed: () {
                                        favoriteHandler.favoriteIconValueMgt(favoriteHandler.getStoredEmail(), value[0]);
                                      }, 
                                      icon: favoriteHandler.favoriteIconValue.value ? const Icon(Icons.favorite, color: Colors.red,) : const Icon(Icons.favorite_border_outlined), 
                                      )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.watch_later_outlined),
                              Text(
                                  "${result[0].startTime}~${result[0].endTime}"),
                              const Icon(Icons.pin_drop_outlined),
                              Text(result[0].address.substring(0, 7))
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(result[0].introduction,
                            style: const TextStyle(
                              fontSize: 15
                            ),
                            ),
                          ),

                          /// 예약 버튼
                          
                            Visibility(
                              visible: reservationHandler.resButtonValue.value,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if(vmHandler.isLoggedIn() == false){
                                      Get.to(()=>Login());
                                    }else{
                                    Get.to(()=>MakeReservation(),
                                    arguments: [
                                      reservationHandler.canReservationClinic[0].id,
                                      reservationHandler.canReservationClinic[0].name,
                                      reservationHandler.canReservationClinic[0].latitude,
                                      reservationHandler.canReservationClinic[0].longitude,
                                      reservationHandler.canReservationClinic[0].time,
                                      reservationHandler.canReservationClinic[0].address,
                                    ]
                                    );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(300, 40),
                                      backgroundColor:
                                          const Color.fromARGB(255, 237, 220, 61)),
                                  child: const Text('예약하기'),
                                ),
                              ),
                            )
                        ],
                      ),
                    );
                  });
                }
              });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/chat_view.dart';
import 'package:vet_app/view/clinic_location.dart';
import 'package:vet_app/view/login.dart';
import 'package:vet_app/view/make_reservation.dart';
import 'package:vet_app/vm/chat_handler.dart';
import 'package:vet_app/vm/favorite_handler.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/reservation_handler.dart';

class ClinicInfo extends StatelessWidget {
  ClinicInfo({super.key});
  final FavoriteHandler vmHandler = Get.find();
  final ChatsHandler chatsHandler = Get.find();
  @override
  Widget build(BuildContext context) {
    FavoriteHandler favoriteHandler = Get.put(FavoriteHandler());
    ReservationHandler reservationHandler = Get.put(ReservationHandler());
    PetHandler petHandler = Get.put(PetHandler());
    var value = Get.arguments ?? "__"; // clinicid = value

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 결과'),
      ),
      body: GetBuilder<FavoriteHandler>(
        builder: (_) {
          return FutureBuilder(
              future: vmHandler.getClinicDetail(),
              builder: (context, snapshot) {
                final result = vmHandler.clinicDetail;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error:${snapshot.error}'));
                } else {
                  favoriteHandler.searchFavoriteClinic(
                      vmHandler.getStoredEmail(),
                      value[0]); // 즐겨찾기 여부 검색 : 즐겨찾기 버튼 관리
                  reservationHandler
                      .reservationButtonMgt(value[0]); // 예약 가능여부 검색 : 예약버튼 활성화
                  return Obx(() {
                    return Center(
                      child: Column(
                        children: [
                          Text(
                            result[0].name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: (MediaQuery.of(context).size.width) * 0.7,
                            height: MediaQuery.of(context).size.height * 0.35,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 4,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        'http://127.0.0.1:8000/clinic/view/${result[0].image}',
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Text('Image'),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.35 *
                                                0.75,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7 *
                                                0.9,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // 지도 보는 버튼
                                          IconButton(
                                              onPressed: () async {
                                                await favoriteHandler
                                                    .getClinicDetail();
                                                await vmHandler
                                                    .checkLocationPermission();
                                                await favoriteHandler
                                                    .maploading(
                                                        favoriteHandler
                                                            .clinicDetail[0]
                                                            .latitude,
                                                        favoriteHandler
                                                            .clinicDetail[0]
                                                            .longitude);
                                                Get.to(() => ClinicLocation(),
                                                    arguments: [result[0].id]);
                                              },
                                              icon: const Icon(
                                                  Icons.pin_drop_outlined,
                                                  size: 35)),

                                          // 즐겨찾기 등록 버튼
                                          IconButton(
                                            onPressed: () async {
                                              await favoriteHandler
                                                  .favoriteIconValueMgt(
                                                      favoriteHandler
                                                          .getStoredEmail(),
                                                      value[0]);
                                              if (favoriteHandler
                                                      .favoriteIconValue
                                                      .value ==
                                                  true) {
                                                showSnackBar(
                                                    '추가성공',
                                                    '즐겨찾기에 등록되었습니다.',
                                                    Colors.green);
                                              } else {
                                                showSnackBar(
                                                    '삭제',
                                                    '즐겨찾기가 삭제되었습니다.',
                                                    Colors.red);
                                              }
                                            },
                                            icon: favoriteHandler
                                                    .favoriteIconValue.value
                                                ? const Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                    size: 35,
                                                  )
                                                : const Icon(
                                                    Icons
                                                        .favorite_border_outlined,
                                                    size: 35,
                                                  ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.watch_later_outlined),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "${result[0].startTime}~${result[0].endTime}"),
                                ),
                                const Icon(Icons.pin_drop_outlined),
                                Text(result[0].address.substring(0, 7))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              result[0].introduction,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),

                          /// 예약 버튼
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                chatsHandler.currentClinicId.value =
                                    result[0].id;
                                await chatsHandler.firstChatRoom(
                                    result[0].id, result[0].image);
                                await chatsHandler.makeChatRoom();
                                await chatsHandler.queryChat();
                                Get.to(() => ChatView(), arguments: [
                                  favoriteHandler.clinicDetail[0].image,
                                  favoriteHandler.clinicDetail[0].name,
                                ]);
                              },
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.7,
                                      50),
                                  backgroundColor:
                                      const Color.fromARGB(255, 237, 220, 61),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              child: const Text(
                                '상담하기',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Visibility(
                              visible: reservationHandler.resButtonValue.value,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (vmHandler.isLoggedIn() == false) {
                                      Get.to(() => Login());
                                    } else {
                                      await petHandler.makeBorderlist();
                                      Get.to(() => MakeReservation(),
                                          arguments: [
                                            reservationHandler
                                                .canReservationClinic[0].id,
                                            reservationHandler
                                                .canReservationClinic[0].name,
                                            reservationHandler
                                                .canReservationClinic[0]
                                                .latitude,
                                            reservationHandler
                                                .canReservationClinic[0]
                                                .longitude,
                                            reservationHandler
                                                .canReservationClinic[0].time,
                                            reservationHandler
                                                .canReservationClinic[0].address
                                          ]);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width * 0.7,
                                        50),
                                    backgroundColor:
                                        const Color.fromARGB(255, 237, 220, 61),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                  child: const Text(
                                    '예약하기',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ))
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

  showSnackBar(String title, String message, Color color) {
    Get.snackbar(title, message,
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        colorText: Colors.black);
  }
}

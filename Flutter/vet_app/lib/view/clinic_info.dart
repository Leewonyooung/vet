import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/clinic_location.dart';
import 'package:vet_app/vm/clinic_handler.dart';
import 'package:vet_app/vm/favorite_handler.dart';

class ClinicInfo extends StatelessWidget {
  ClinicInfo({super.key});
  final ClinicHandler vmHandler = Get.find();
  @override
  Widget build(BuildContext context) {
    FavoriteHandler favoriteHandler = Get.put(FavoriteHandler());
    var value = Get.arguments[0] ?? "__"; // clinicid = value
    favoriteHandler.searchFavoriteClinic(vmHandler.getStoredEmail(), value);
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 결과'),
      ),
      body: GetBuilder<ClinicHandler>(
        builder: (_) {
          return FutureBuilder(
              future: vmHandler.getClinicDetail(value),
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
                                            onPressed: () => Get.to(() =>
                                                ClinicLocation(),
                                                arguments: [result[0].id]),
                                            icon: const Icon(
                                                Icons.pin_drop_outlined)),

                                        // 즐겨찾기 등록 버튼
                                      IconButton(
                                        onPressed: () {
                                        favoriteHandler.favoriteIconValueMgt(favoriteHandler.getStoredEmail(), value);
                                      }, 
                                      icon: favoriteHandler.favoriteIconValue.value ? Icon(Icons.favorite, color: Colors.red,) : Icon(Icons.favorite_border_outlined), 
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

                          /// 예약 버튼
                          Padding(
                            padding: const EdgeInsets.all(60),
                            child: ElevatedButton(
                              onPressed: () {
                              },
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(300, 40),
                                  backgroundColor:
                                      const Color.fromARGB(255, 237, 220, 61)),
                              child: const Text('예약하기'),
                            ),
                          ),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/clinic_info.dart';
import 'package:vet_app/vm/favorite_handler.dart';

class ClinicSearch extends StatelessWidget {
  ClinicSearch({super.key});

  final FavoriteHandler vmHandler = Get.put(FavoriteHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('검색'),
        ),
        body: GetBuilder<FavoriteHandler>(
          builder: (_) {
            return FutureBuilder(
              future: vmHandler.getAllClinic(),
              builder: (context, snapshot) {
              return Column(
                children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SearchBar(
                        controller: vmHandler.searchbarController,
                        onChanged: (value) {
                          vmHandler.searchbarController.text = value;
                          vmHandler.searchMGT();
                        },
                      ),
                    ),
                  Expanded(
                    child: Obx(() {
                      return Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 1.5,
                            child: ListView.builder(
                              itemCount: vmHandler.clinicSearch.length,
                              itemBuilder: (context, index) {
                                final clinic = vmHandler.clinicSearch;
                                return GestureDetector(
                                  onTap: () {
                                    vmHandler.resetTextfield();
                                    vmHandler
                                        .updateCurrentIndex(clinic[index].id);
                                    Get.to(() => ClinicInfo(),
                                    arguments: [
                                      clinic[index].id
                                    ]
                                    );
                                    
                                  },
                                  child: Card(
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          clinic[index].image.isEmpty ? const Icon(Icons.local_hospital) :
                                          Image.network(
                                              'http://127.0.0.1:8000/clinic/view/${clinic[index].image}',
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  clinic[index].name,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  clinic[index].address,
                                                  overflow: TextOverflow.ellipsis,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                      // }
                    }),
                  ),
                ],
              );
              }
            );
          },
        ));
  }
}

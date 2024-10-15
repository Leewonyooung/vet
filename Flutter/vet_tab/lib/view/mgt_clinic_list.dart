import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_tab/view/mgt_clinic_edit.dart';
import 'package:vet_tab/vm/clinic_handler.dart';

class MgtClinicList extends StatelessWidget {
  MgtClinicList({super.key});

  final TextEditingController searchKeywardController = TextEditingController();
  final ClinicHandler clinicHandler = Get.put(ClinicHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('검색'),
        ),
        body: GetBuilder<ClinicHandler>(
          builder: (_) {
            return FutureBuilder(
                future: clinicHandler.getAllClinic(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('다시 시도하세요'));
                  } else {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SearchBar(
                            controller: searchKeywardController,
                            onChanged: (value) {
                              //
                            },
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 1.5,
                          child: ListView.builder(
                            itemCount: clinicHandler.clinicSearch.length,
                            itemBuilder: (context, index) {
                              final clinic = clinicHandler.clinicSearch;
                              return GestureDetector(
                                onTap: () async{
                                  await clinicHandler.getClinicDetail(clinic[index].id);
                                  clinicHandler
                                      .updateCurrentIndex(clinic[index].id);
                                  Get.to(() => MgtClinicEdit(), arguments: [
                                    clinic[index].id,
                                  ]);
                                },
                                child: Card(
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
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
                  }
                });
          },
        ));
  }
}
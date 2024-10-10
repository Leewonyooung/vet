import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/clinic_info.dart';
import 'package:vet_app/vm/clinic_handler.dart';

class ClinicSearch extends StatelessWidget {
  ClinicSearch({super.key});

  final TextEditingController searchKeywardController = TextEditingController();
  final ClinicHandler vmHandler = Get.put(ClinicHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('검색'),
        ),
        body: GetBuilder<ClinicHandler>(
          builder: (controller) {
            return FutureBuilder(
                future: controller.getAllClinic(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error:${snapshot.error}'));
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
                            itemCount: vmHandler.clinicSearch.length,
                            itemBuilder: (context, index) {
                              final clinic = vmHandler.clinicSearch;
                              return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 100,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(const ClinicInfo(), arguments: [
                                      clinic[index].id,
                                    ]);
                                  },
                                  child: Card(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        index % 2 == 0
                                            ? const Icon(Icons.pets)
                                            : const Icon(Icons.local_hospital),
                                        Text(clinic[index].name),
                                        clinic[index].address.length > 4
                                            ? Text(clinic[index]
                                                .address
                                                .substring(0, 8))
                                            : Text(clinic[index].address),
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

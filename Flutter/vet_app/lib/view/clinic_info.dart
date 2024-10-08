import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/clinic_location.dart';
import 'package:vet_app/vm/vm_handler.dart';

class ClinicInfo extends StatelessWidget {
  const ClinicInfo({super.key});

  @override
  Widget build(BuildContext context) {
    VmHandler vmHandler = Get.put(VmHandler());
    var value = Get.arguments[0] ??"__";
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 결과'),
      ),
      body: GetBuilder<VmHandler>(
        builder: (controller) {
          return FutureBuilder(
              future: controller.getClinicDetail(value),
              builder: (context, snapshot) {
                final result = vmHandler.clinicDetail;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error:${snapshot.error}'));
                } else {
                  return Center(
                    child: Column(
                      children: [
                        Text(result[0].name),
                        Container(
                          width: (MediaQuery.of(context).size.width),
                          height: 250,
                          color: Colors.grey,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                  onPressed: () => Get.to(const ClinicLocation(),
                                          arguments: [
                                            result[0].name,
                                            result[0].latitude,
                                            result[0].longitude,
                                            result[0].address
                                          ]
                                          ),
                                  icon: const Icon(Icons.pin_drop_outlined)),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.favorite_border))
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.watch_later_outlined),
                            Text("${result[0].startTime}~${result[0].endTime}"),
                            const Icon(Icons.pin_drop_outlined),
                            result[0].address=='null' ? const Text('주소 미입력') : Text(result[0].address.substring(0, 8))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(60),
                          child: ElevatedButton(
                            onPressed: () {
                              //
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
                }
              });
        },
      ),
    );
  }
}

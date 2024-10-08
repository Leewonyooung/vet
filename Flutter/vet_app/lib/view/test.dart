import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/vm_handler.dart';

class Test extends StatelessWidget {
  Test({super.key});
  var value = Get.arguments ?? "__";

  @override
  Widget build(BuildContext context) {
    final VmHandler vmHandler = Get.put(VmHandler());
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: GetBuilder<VmHandler>(builder: (controller) {
          print(value[0]);
          print(value[1]);
          print(vmHandler.userEmail);
          return Obx(
            () {
              return ListView.builder(
                itemCount: vmHandler.userdata.length,
                itemBuilder: (context, index) {
                  final saveddata = vmHandler.savedData[index];
                  print(saveddata.name);
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("id : ${saveddata.id}"),
                        Text("password : ${saveddata.password}"),
                        Text("image : ${saveddata.image}"),
                        Text("name : ${saveddata.name}"),
                      ],
                    ),
                  );
                },
              );
            },
          );
        }));
  }
}

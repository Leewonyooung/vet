import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/vm_handler.dart';

class QueryReservation extends StatelessWidget {
  const QueryReservation({super.key});

  @override
  Widget build(BuildContext context) {
    final vmHandler = PetHandler();
    TextEditingController symptomsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('긴급 예약'),
      ),
      // body: GetBuilder<VmHandler>(
      //   builder: (controller) {
      //     return FutureBuilder(
      //       future: controller., 
      //       builder: (context, snapshot) {
      //         if (snapshot.connectionState == ConnectionState.waiting) {
      //             return const Center(
      //               child: CircularProgressIndicator(),
      //             );
      //         } else if (snapshot.hasError) {
      //             return Center(
      //               child: Text('Error : ${snapshot.error}'),
      //             );
      //           } else{
      //           }
      //       },
      //     );
      //   },
      // ),
    );
  }
}

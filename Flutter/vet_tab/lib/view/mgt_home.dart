import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_tab/view/mgt_clinic_add.dart';
import 'package:vet_tab/view/mgt_clinic_list.dart';
import 'package:vet_tab/vm/species_handler.dart';

class MgtHome extends StatelessWidget {
  MgtHome({super.key});
  final speciesHandler = Get.put(SpeciesHandler());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('개발자 페이지'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => MgtClinicAdd());
                    },
                    child: const Text('새로운 병원 추가')),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => MgtClinicList());
                    },
                    child: const Text('병원 정보 변경')),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      speciesHandler.speciesController.clear();
                      speciesHandler.speciesInsertDialog();
                    },
                    child: const Text('견종 추가하기')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

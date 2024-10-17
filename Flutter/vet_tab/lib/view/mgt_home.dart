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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '관리자 페이지',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildElevatedButton(
                '새로운 병원 추가',
                () => Get.to(() => MgtClinicAdd()),
              ),
              const SizedBox(height: 16),
              _buildElevatedButton(
                '병원 정보 변경',
                () => Get.to(() => MgtClinicList()),
              ),
              const SizedBox(height: 16),
              _buildElevatedButton(
                '견종 추가하기',
                () {
                  speciesHandler.speciesController.clear();
                  speciesHandler.speciesInsertDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

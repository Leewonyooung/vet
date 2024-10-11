import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_tab/view/mgt_clinic_add.dart';

class MgtHome extends StatelessWidget {
  const MgtHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Page'),
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
                  child: const Text('Create Clinic account')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    //
                  },
                  child: const Text('Create Species')),
            ),
          ],
        ),
      ),
    );
  }
}

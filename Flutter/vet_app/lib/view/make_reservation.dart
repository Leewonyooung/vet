import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/query_reservation.dart';
import 'package:vet_app/view/reservation_complete.dart';
import 'package:vet_app/vm/pet_handler.dart';

// 긴급 예약 확정페이지
class MakeReservation extends StatelessWidget {
  MakeReservation({super.key});
  final vmHnadler = Get.put(PetHandler());
  var value = Get.arguments;

  @override
  Widget build(BuildContext context) {
    TextEditingController symptomsController = TextEditingController();
    vmHnadler.fetchPets(vmHnadler.getStoredEmail());
    final pet = vmHnadler.pets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('긴급 예약'),
      ),
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vmHnadler.pets.length,
        itemBuilder: (context, index) {
          final pet = vmHnadler.pets[index];
          return SizedBox(
            height: 300,
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('내 반려동물'),
                Card(
                  child: Row(
                    children: [
                      // Image.network('http://127.0.0.1:8000/pet/pets/${pet.image}'),
                      Column(
                        children: [
                          Text('이름 : ${pet.name}'),
                          Row(
                            children: [
                              getGenderIcon(pet.gender),
                              Text(pet.speciesCategory)
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text('증상'),
                TextField(
                  maxLines: 4,
                  controller: symptomsController,
                ),
                ElevatedButton(
                  onPressed: () {
                    checkReservation();
                  },
                  child: const Text('예약하기'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // -- Functions ---
  Icon getGenderIcon(String gender) {
    // 입력된 pet gender에 따라 아이콘을 반환
    if (gender == "수컷") {
      return const Icon(Icons.male);
    } else if (gender == "암컷") {
      return const Icon(Icons.female);
    } else {
      return const Icon(Icons.help); // null값일때
    }
  }

  checkReservation() {
    Get.defaultDialog(
        title: '예약하기',
        titleStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        middleText: '예약을 확정 하시겠습니까?',
        actions: [
          ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('아니오')),
          ElevatedButton(onPressed: () {
            Get.to(QueryReservation(), arguments: [
              value[0], // clinic.name,
              value[1], // clinic.latitude,
              value[2], // clinic.longitude,
              value[3], // clinic.image,
              value[4],  // clinic.time
              value[5],  // clinic.address
              
            ]);
          }, child: const Text('확정')),
        ]);
  }
}

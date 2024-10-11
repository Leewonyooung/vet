import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/pet_handler.dart';

class QueryReservation extends StatelessWidget {
  QueryReservation({super.key});
  final vmHnadler = Get.put(PetHandler());

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
          return Card(
            child: Row(
              children: [
                Image.network('http://127.0.0.1:8000/pet/pets/${pet.image}'),
                Column(
                  children: [
                    Text('이름 : ${pet.name}'),
                    Row(
                      children: [const Icon(Icons.female), Text(pet.speciesCategory)],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

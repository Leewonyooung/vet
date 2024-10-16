import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/pet_register.dart';
import 'package:vet_app/view/reservation_complete.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/reservation_handler.dart';

// 긴급 예약 확정페이지
class MakeReservation extends StatelessWidget {
  MakeReservation({super.key});
  final LoginHandler loginHandler = Get.find();
  final PetHandler petHandler = Get.find();
  final ReservationHandler reservationHandler = Get.put(ReservationHandler());
  final value = Get.arguments;

  @override
  Widget build(BuildContext context) {
    TextEditingController symptomsController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '긴급 예약',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '내 반려동물',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildPetList(context),
              const SizedBox(height: 30),
              const Text(
                '증상',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildSymptomsField(symptomsController),
              const SizedBox(height: 30),
              _buildReservationButton(context, symptomsController),
            ],
          ),
        ),
      ),
    );
  }

  _buildPetList(BuildContext context) {
    return SizedBox(
      height: 220,
      child: GetBuilder<PetHandler>(
        builder: (_) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: petHandler.pets.length + 1,
            itemBuilder: (context, index) {
              if (index == petHandler.pets.length) {
                return _buildAddPetCard(context);
              }
              return _buildPetCard(context, index);
            },
          );
        },
      ),
    );
  }

  _buildAddPetCard(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var result = await Get.to(() => PetRegister());
        if (result == true) {
          petHandler.fetchPets(loginHandler.box.read('userEmail'));
        }
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const SizedBox(
          width: 160,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 50,
                color: Colors.green,
              ),
              SizedBox(height: 10),
              Text(
                '반려동물 등록',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildPetCard(BuildContext context, int index) {
    final pet = petHandler.pets[index];
    String baseUrl = 'http://127.0.0.1:8000';
    String imageUrl = '$baseUrl/pet/uploads/${pet.image}';

    return Obx(() {
      return GestureDetector(
        onTap: () {
          petHandler.setborder(index);
          petHandler.fetchPets(loginHandler.box.read('userEmail'));
          petHandler.currentPetID.value = petHandler.pets[index].id;
        },
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: petHandler.borderList[index],
              width: 2,
            ),
          ),
          child: SizedBox(
            width: 160,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error,
                        size: 120,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '종류: ${pet.speciesType}',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '성별: ${pet.gender}',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  _buildSymptomsField(TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: '증상을 입력해주세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
      ),
    );
  }

  _buildReservationButton(
      BuildContext context, TextEditingController symptomsController) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () =>
            _showReservationConfirmDialog(context, symptomsController),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightGreen.shade300,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          '예약하기',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  _showReservationConfirmDialog(
      BuildContext context, TextEditingController symptomsController) {
    Get.defaultDialog(
      title: '예약하기',
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      middleText: '예약을 확정 하시겠습니까?',
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            '아니오',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Get.offAll(
              () => ReservationComplete(),
              arguments: [
                value[0],
                value[1],
                value[2],
                value[3],
                value[4],
                value[5],
              ],
            );
            reservationHandler.makeReservation(
                loginHandler.box.read('userEmail'),
                value[0],
                value[4],
                symptomsController.text,
                petHandler.currentPetID.value);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
          ),
          child: const Text(
            '확정',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

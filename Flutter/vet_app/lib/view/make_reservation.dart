import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/pet_register.dart';
import 'package:vet_app/view/reservation_complete.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/reservation_handler.dart';

class MakeReservation extends StatelessWidget {
  MakeReservation({super.key});
  final LoginHandler loginHandler = Get.find();
  final PetHandler petHandler = Get.find();
  final ReservationHandler reservationHandler = Get.put(ReservationHandler());
  final value = Get.arguments;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    TextEditingController symptomsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '긴급 예약',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '내 반려동물',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              _buildPetList(context, screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.04),
              Text(
                '증상',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildSymptomsField(symptomsController, screenWidth),
              SizedBox(height: screenHeight * 0.04),
              _buildReservationButton(context, symptomsController, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetList(
      BuildContext context, double screenWidth, double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.3,
      child: GetBuilder<PetHandler>(
        builder: (_) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: petHandler.pets.length + 1,
            itemBuilder: (context, index) {
              if (index == petHandler.pets.length) {
                return _buildAddPetCard(context, screenWidth, screenHeight);
              }
              return _buildPetCard(context, index, screenWidth, screenHeight);
            },
          );
        },
      ),
    );
  }

  Widget _buildAddPetCard(
      BuildContext context, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: () async {
        var result = await Get.to(() => PetRegister());
        if (result == true) {
          petHandler.fetchPets(loginHandler.box.read('userEmail'));
        }
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(screenWidth * 0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        child: SizedBox(
          width: screenWidth * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: screenWidth * 0.12,
                color: Colors.green,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                '반려동물 등록',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
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

  Widget _buildPetCard(BuildContext context, int index, double screenWidth,
      double screenHeight) {
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
          margin: EdgeInsets.all(screenWidth * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            side: BorderSide(
              color: petHandler.borderList[index],
              width: 2,
            ),
          ),
          child: SizedBox(
            width: screenWidth * 0.4,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(screenWidth * 0.03),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.2,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '종류: ${pet.speciesType}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      Text(
                        '성별: ${pet.gender}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
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

  Widget _buildSymptomsField(
      TextEditingController controller, double screenWidth) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: '증상을 입력해주세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildReservationButton(BuildContext context,
      TextEditingController symptomsController, double screenWidth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () =>
            _showReservationConfirmDialog(context, symptomsController),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightGreen.shade300,
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
        ),
        child: Text(
          '예약하기',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
          ),
        ),
      ),
    );
  }

  void _showReservationConfirmDialog(
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/login.dart';
import 'package:vet_app/view/pet_register.dart';
import 'package:vet_app/view/query_reservation.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/pet_handler.dart';

// 긴급 예약 확정페이지
class MakeReservation extends StatelessWidget {
  MakeReservation({super.key});
  final LoginHandler loginHandler = Get.put(LoginHandler());
  final PetHandler petHandler = Get.put(PetHandler());
  final value = Get.arguments;

  @override
  Widget build(BuildContext context) {
    TextEditingController symptomsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('긴급 예약'),
      ),
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: petHandler.pets.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 300,
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('내 반려동물',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),)
                ,
                const SizedBox(height: 20),
                Obx(() {
                  if (!loginHandler.isLoggedIn()) {
                    return _buildRegisterBanner();
                  }

                  if (!petHandler.hasPets()) {
                    return _buildRegisterBanner();
                  }

                  return _buildPetInfoList();
                }),
                const Text('증상',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),),
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
            Get.to(()=> const QueryReservation());
          }, child: const Text('확정')),
        ]);
  }

  Widget _buildRegisterBanner() {
    return GestureDetector(
      onTap: () {
        if (loginHandler.isLoggedIn()) {
          Get.to(const PetRegister());
        } else {
          Get.to( Login());
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.pets, size: 40),
            SizedBox(width: 10),
            Text(
              '내가 키우는 반려동물을 등록해 보세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetInfoList() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: petHandler.pets.length + 1, // 반려동물 수에 추가 버튼 포함
        itemBuilder: (context, index) {
          if (index == petHandler.pets.length) {
            // 반려동물 등록 버튼 추가
            return GestureDetector(
              onTap: () async {
                // PetRegister 페이지에서 돌아올 때 결과 확인
                var result = await Get.to(() => const PetRegister());

                // 등록 후 화면 갱신
                if (result == true) {
                  // 반려동물 정보 다시 로드
                  String userId = loginHandler.getStoredEmail();
                  petHandler.fetchPets(userId);
                }
              },
              child: const Card(
                elevation: 4,
                margin: EdgeInsets.all(8),
                child: SizedBox(
                  width: 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 40),
                      SizedBox(height: 10),
                      Text(
                        '반려동물 등록',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // 기존 반려동물 정보 표시
          final pet = petHandler.pets[index];
          String baseUrl = 'http://127.0.0.1:8000'; // 서버 주소
          String imageUrl = '$baseUrl/pet/uploads/${pet.image}'; // 이미지 경로 조합

          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(10),
              width: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지 불러오기 (왼쪽)
                  Image.network(
                    imageUrl,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error,
                        size: 150,
                      ); // 이미지 로드 실패 시
                    },
                  ),
                  const SizedBox(width: 10), // 이미지와 텍스트 사이 간격
                  // 텍스트 정보 (오른쪽)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text('종류: ${pet.speciesType}'),
                        Text('성별: ${pet.gender}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

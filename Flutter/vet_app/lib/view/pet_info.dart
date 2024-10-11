import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/model/pet.dart';

class PetInfo extends StatelessWidget {
  const PetInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // PetHandler를 가져와서 서버에서 반려동물 데이터를 불러옵니다.
    final PetHandler petHandler = Get.find<PetHandler>();

    // UI가 로딩될 때 반려동물 데이터를 가져옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 로그인한 사용자 ID를 사용하여 반려동물 정보를 가져옴
      String userId = Get.arguments; // arguments로 전달된 사용자 ID
      petHandler.fetchPets(userId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('반려동물 정보'),
      ),
      body: Obx(() {
        // 데이터를 불러오는 동안 로딩 스피너 표시
        if (petHandler.pets.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 불러온 반려동물 데이터를 리스트뷰로 출력
        return ListView.builder(
          itemCount: petHandler.pets.length,
          itemBuilder: (context, index) {
            final Pet pet = petHandler.pets[index];

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: pet.image != null
                    ? Image.network(
                        pet.image!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.pets, size: 50),
                title: Text(pet.name),
                subtitle: Text(
                  '종류: ${pet.speciesType}\n세부 종류: ${pet.speciesCategory}\n생일: ${pet.birthday}',
                ),
                onTap: () {
                  // 선택한 반려동물의 상세 정보를 보여줌
                  Get.defaultDialog(
                    title: pet.name,
                    middleText: '''
                    종류: ${pet.speciesType}
                    세부 종류: ${pet.speciesCategory}
                    생일: ${pet.birthday}
                    특징: ${pet.features}
                    성별: ${pet.gender}
                    ''',
                    textConfirm: '확인',
                    onConfirm: () => Get.back(),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/pet.dart';
import 'package:vet_app/view/navigation.dart';
import 'package:vet_app/view/pet_update.dart';
import 'package:vet_app/vm/pet_handler.dart';

class PetInfo extends StatelessWidget {
  final Pet pet;
  final PetHandler petHandler = Get.find<PetHandler>();

  PetInfo({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final updatedPet = petHandler.getPet(pet.id);
          return Text(updatedPet != null ? '${updatedPet.name} 정보' : '반려동물 정보');
        }),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedPet = petHandler.getPet(pet.id);
              if (updatedPet != null) {
                final result = await Get.to(() => PetUpdate(pet: updatedPet));
                if (result == true) {
                  petHandler.fetchPets(pet.userId);
                }
              } else {
                Get.snackbar('알림', '해당 반려동물 정보가 존재하지 않습니다.');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('반려동물 삭제'),
                  content: Text('${pet.name}을(를) 정말 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      child: const Text('취소'),
                      onPressed: () => Get.back(),
                    ),
                    TextButton(
                      child: const Text('삭제'),
                      onPressed: () async {
                        final success = await petHandler.deletePet(pet.id);
                        if (success) {
                          Get.back(); // 다이얼로그 닫기
                          Get.offAll(() => Navigation()); // 첫 화면으로 이동
                        } else {
                          Get.snackbar('오류', '반려동물 삭제에 실패했습니다.');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final updatedPet = petHandler.getPet(pet.id);
        if (updatedPet == null) {
          // 반려동물이 삭제되었을 경우 처리
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAll(() => Navigation()); // 첫 화면으로 이동
            Get.snackbar('알림', '해당 반려동물 정보가 삭제되었습니다.');
          });
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이름: ${updatedPet.name}',
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              Text('Id: ${updatedPet.id}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('종류: ${updatedPet.speciesType}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('세부 종류: ${updatedPet.speciesCategory}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('성별: ${updatedPet.gender}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('특징: ${updatedPet.features}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('생일: ${updatedPet.birthday}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              Image.network(
                'http://127.0.0.1:8000/pet/uploads/${updatedPet.image}',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 200);
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

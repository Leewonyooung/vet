import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/pet.dart';
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
        title: Text('${pet.name} 정보'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // 수정 페이지로 이동
              final result = await Get.to(() => PetUpdate(pet: pet));
              if (result == true) {
                // 수정이 성공적으로 이루어졌다면 반려동물 정보를 새로고침합니다.
                petHandler.fetchPets(pet.userId);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // 삭제 확인 다이얼로그 표시
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
                        // 반려동물 삭제 로직 실행
                        final success = await petHandler.deletePet(pet.id);
                        if (success) {
                          Get.back();
                          Get.back();
                          Get.snackbar('성공', '반려동물이 삭제되었습니다.');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이름: ${pet.name}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text('Id: ${pet.id}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('종류: ${pet.speciesType}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('세부 종류: ${pet.speciesCategory}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('성별: ${pet.gender}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('특징: ${pet.features}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('생일: ${pet.birthday}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Image.network(
              'http://127.0.0.1:8000/pet/uploads/${pet.image}',
              height: 200,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 200); // 이미지 로드 실패 시
              },
            ),
          ],
        ),
      ),
    );
  }
}

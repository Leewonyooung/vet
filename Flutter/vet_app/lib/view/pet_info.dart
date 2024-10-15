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
        // 타이틀 : {반려동물 이름} 정보
        title: Obx(() {
          final updatedPet = petHandler.getPet(pet.id);
          return Text(
            updatedPet != null ? '${updatedPet.name} 정보' : '반려동물 정보',
            style: const TextStyle(color: Colors.white),
          );
        }),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          // 수정 버튼
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _editPet(context),
          ),
          // 삭제 버튼
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _deletePet(context),
          ),
        ],
      ),
      body: Obx(() {
        final updatedPet = petHandler.getPet(pet.id);
        // 반려동물 정보가 없는 경우 (삭제된 경우) 처리
        if (updatedPet == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAll(() => Navigation());
            Get.snackbar(
              '알림',
              '해당 반려동물 정보가 삭제되었습니다.',
            );
          });
          return const Center(child: CircularProgressIndicator());
        }
        // 반려동물 정보 표시
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildPetImage(updatedPet),
              _buildPetInfo(updatedPet),
            ],
          ),
        );
      }),
    );
  }

  // --- Functions ---

  // 반려동물 이미지
  _buildPetImage(Pet updatedPet) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Image.network(
        'http://127.0.0.1:8000/pet/uploads/${updatedPet.image}',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // 이미지 로드 실패 시 에러 아이콘 + 메시지
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  size: 150,
                ),
                SizedBox(height: 10),
                Text('이미지를 불러올 수 없습니다'),
              ],
            ),
          );
        },
      ),
    );
  }

  // 반려동물 상세 정보 표시
  _buildPetInfo(Pet updatedPet) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTile('이름', updatedPet.name, Icons.pets),
          _buildInfoTile('ID', updatedPet.id, Icons.tag),
          _buildInfoTile('종류', updatedPet.speciesType, Icons.category),
          _buildInfoTile('세부 종류', updatedPet.speciesCategory, Icons.details),
          _buildInfoTile(
            '성별',
            updatedPet.gender,
            updatedPet.gender == '수컷' ? Icons.male : Icons.female,
          ),
          _buildInfoTile('특징', updatedPet.features, Icons.description),
          _buildInfoTile('생일', updatedPet.birthday, Icons.cake),
        ],
      ),
    );
  }

  // 반려동물 정보 목록
  _buildInfoTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 반려동물 정보 수정
  _editPet(BuildContext context) async {
    final updatedPet = petHandler.getPet(pet.id);
    if (updatedPet != null) {
      final result = await Get.to(() => PetUpdate(pet: updatedPet));
      if (result == true) {
        // 수정 성공 시 반려동물 정보 새로고침
        petHandler.fetchPets(pet.userId);
      }
    } else {
      Get.snackbar(
        '알림',
        '해당 반려동물 정보가 존재하지 않습니다.',
      );
    }
  }

  // 반려동물 삭제
  _deletePet(BuildContext context) {
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
                Get.back();
                Get.offAll(() => Navigation());
              } else {
                Get.snackbar(
                  '오류',
                  '반려동물 삭제에 실패했습니다.',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

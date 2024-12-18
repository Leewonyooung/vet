import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/model/pet.dart';
import 'package:vet_app/view/navigation.dart';
import 'package:vet_app/view/pet_update.dart';
import 'package:vet_app/vm/pet_handler.dart';

class PetInfo extends StatelessWidget {
  final Pet pet;
  final PetHandler petHandler = Get.find();

  PetInfo({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final updatedPet = petHandler.getPet(pet.id);
          return Text(
            updatedPet != null ? '${updatedPet.name} 정보' : '반려동물 정보',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
        centerTitle: true,
        backgroundColor: Colors.green.shade400,
        actions: [
          IconButton(
            icon:
                Icon(Icons.edit, size: screenWidth * 0.07, color: Colors.white),
            onPressed: () => _editPet(context),
          ),
          IconButton(
            icon: Icon(Icons.delete,
                size: screenWidth * 0.07, color: Colors.white),
            onPressed: () => _deletePet(context),
          ),
        ],
      ),
      body: Obx(() {
        final updatedPet = petHandler.getPet(pet.id);
        if (updatedPet == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAll(() => Navigation());
            Get.snackbar('알림', '해당 반려동물 정보가 삭제되었습니다.');
          });
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildPetImage(updatedPet, screenWidth, screenHeight),
              _buildPetInfo(updatedPet, screenWidth),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPetImage(
      Pet updatedPet, double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.3,
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 2,
            blurRadius: 7,
          ),
        ],
      ),
      child: CachedNetworkImage(
        imageUrl: updatedPet.image!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: screenWidth * 0.2,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: screenWidth * 0.2,
          child: const CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: screenWidth * 0.2,
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildPetInfo(Pet updatedPet, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTile('이름', updatedPet.name, Icons.pets, screenWidth),
          _buildInfoTile('ID', updatedPet.id, Icons.tag, screenWidth),
          _buildInfoTile(
              '종류', updatedPet.speciesType, Icons.category, screenWidth),
          _buildInfoTile(
              '세부 종류', updatedPet.speciesCategory, Icons.details, screenWidth),
          _buildInfoTile(
            '성별',
            updatedPet.gender,
            updatedPet.gender == '수컷' ? Icons.male : Icons.female,
            screenWidth,
          ),
          _buildInfoTile(
              '특징', updatedPet.features, Icons.description, screenWidth),
          _buildInfoTile('생일', updatedPet.birthday, Icons.cake, screenWidth),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      String title, String value, IconData icon, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        children: [
          Icon(icon, size: screenWidth * 0.07, color: Colors.lightGreen),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
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

  void _editPet(BuildContext context) async {
    final updatedPet = petHandler.getPet(pet.id);
    if (updatedPet != null) {
      final result = await Get.to(() => PetUpdate(pet: updatedPet));
      if (result == true) {
        petHandler.fetchPets(pet.userId);
      }
    } else {
      Get.snackbar('알림', '해당 반려동물 정보가 존재하지 않습니다.');
    }
  }

  void _deletePet(BuildContext context) {
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
                Get.snackbar('오류', '반려동물 삭제에 실패했습니다.');
              }
            },
          ),
        ],
      ),
    );
  }
}

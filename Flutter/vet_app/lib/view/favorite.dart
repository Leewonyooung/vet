import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/clinic_info.dart';
import 'package:vet_app/vm/favorite_handler.dart';
import 'package:vet_app/vm/login_handler.dart';

class Favorite extends StatelessWidget {
  Favorite({super.key});
  final FavoriteHandler favoriteHandler = Get.find();
  final LoginHandler loginHandler = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '찜한 병원 목록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: GetBuilder<FavoriteHandler>(
        builder: (_) {
          if (favoriteHandler.favoriteClinics.isEmpty) {
            return _buildEmptyState();
          }
          return _buildFavoriteList();
        },
      ),
    );
  }

  // 즐겨찾기 목록이 비어있을 때
  _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '즐겨찾기 목록이 비어있습니다.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 즐겨찾기 목록
  _buildFavoriteList() {
    return ListView.builder(
      itemCount: favoriteHandler.favoriteClinics.length,
      itemBuilder: (context, index) {
        final clinic = favoriteHandler.favoriteClinics[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () async {
              await favoriteHandler.updateCurrentIndex(clinic.id);
              Get.to(() => ClinicInfo(), arguments: [clinic.id]);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildClinicImage(clinic),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clinic.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          clinic.address,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '전화: ${clinic.phone}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => _showDeleteConfirmation(
                        loginHandler.box.read('userEmail'), clinic.id),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 병원 사진
  _buildClinicImage(dynamic clinic) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        'http://127.0.0.1:8000/clinic/view/${clinic.image}',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
            child: const Icon(Icons.local_hospital, color: Colors.white),
          );
        },
      ),
    );
  }

// 즐겨찾기 삭제 확인
  _showDeleteConfirmation(String userId, String clinicId) {
    Get.dialog(
      AlertDialog(
        title: const Text('즐겨찾기 삭제'),
        content: const Text('이 병원을 즐겨찾기에서 삭제하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            child: const Text('취소'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('삭제'),
            onPressed: () {
              favoriteHandler.removeFavoriteClinic(userId, clinicId);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

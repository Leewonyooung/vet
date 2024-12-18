import 'package:cached_network_image/cached_network_image.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '찜한 병원 목록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: screenWidth * 0.05,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: GetBuilder<FavoriteHandler>(
        builder: (_) {
          if (favoriteHandler.favoriteClinics.isEmpty) {
            return _buildEmptyState(screenWidth, screenHeight);
          }
          return _buildFavoriteList(screenWidth, screenHeight);
        },
      ),
    );
  }

  // 즐겨찾기 목록이 비어있을 때
  Widget _buildEmptyState(double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: screenWidth * 0.2,
            color: Colors.grey[400],
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            '즐겨찾기 목록이 비어있습니다.',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 즐겨찾기 목록
  Widget _buildFavoriteList(double screenWidth, double screenHeight) {
    return FutureBuilder(
      future: favoriteHandler
          .getFavoriteClinics(Get.find<LoginHandler>().box.read('userEmail')),
      builder: (context, snapshot) {
        return ListView.builder(
          itemCount: favoriteHandler.favoriteClinics.length,
          itemBuilder: (context, index) {
            final clinic = favoriteHandler.favoriteClinics[index];
            return Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.01,
              ),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: InkWell(
                onTap: () async {
                  await favoriteHandler.updateCurrentIndex(clinic.id);
                  Get.to(() => ClinicInfo(), arguments: [clinic.id]);
                },
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildClinicImage(
                        clinic,
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.2,
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clinic.name,
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenWidth * 0.01),
                            Text(
                              clinic.address,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: screenWidth * 0.04,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenWidth * 0.01),
                            Text(
                              '전화: ${clinic.phone}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: screenWidth * 0.06,
                        ),
                        onPressed: () => _showDeleteConfirmation(
                          loginHandler.box.read('userEmail'),
                          clinic.id,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 병원 사진
  Widget _buildClinicImage(dynamic clinic,
      {double width = 80, double height = 80}) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: "${favoriteHandler.server}/clinic/view/${clinic.image}",
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  // 즐겨찾기 삭제 확인
  void _showDeleteConfirmation(String userId, String clinicId) {
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

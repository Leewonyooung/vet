import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/clinic_location.dart';
import 'package:vet_app/vm/favorite_handler.dart';
import 'package:vet_app/vm/login_handler.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    // FavoriteHandler 인스턴스 생성
    final FavoriteHandler favoriteHandler = Get.put(FavoriteHandler());

    final LoginHandler loginHandler = Get.find<LoginHandler>();

    // 로그인한 사용자의 ID(email)를 사용
    String userId = loginHandler.getStoredEmail(); // 저장된 이메일 가져오기

    // 즐겨찾기 목록 불러오기 호출
    favoriteHandler.getFavoriteClinics(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('찜한 병원 목록'),
      ),
      body: GetBuilder<FavoriteHandler>(
        builder: (controller) {
          // 로딩 상태 처리
          if (controller.favoriteClinics.isEmpty) {
            return const Center(
              child: Text('즐겨찾기 목록이 비어있습니다.'),
            );
          }

          // 즐겨찾기 목록을 리스트뷰로 출력
          return ListView.builder(
            itemCount: controller.favoriteClinics.length,
            itemBuilder: (context, index) {
              final clinic = controller.favoriteClinics[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.local_hospital),
                  title: Text(clinic.name),
                  subtitle: Text('${clinic.address}\n전화: ${clinic.phone}'),
                  onTap: () {
                    // 병원 ID를 넘겨서 clinic_location.dart 페이지로 이동
                    Get.to(
                      () => const ClinicLocation(),
                      arguments: clinic.id, // 병원의 ID 넘기기
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // 즐겨찾기에서 병원 삭제
                      favoriteHandler.removeFavoriteClinic(
                        userId, // 로그인한 사용자 ID 사용
                        clinic.id, // String? 타입을 String으로 변환
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

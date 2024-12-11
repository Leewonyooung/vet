import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/myinfo_update.dart';
import 'package:vet_app/view/navigation.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/token_access.dart';

class Mypage extends StatelessWidget {
  Mypage({super.key});
  final LoginHandler loginHandler = Get.find();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '마이페이지',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: loginHandler.isLoggedIn()
          ? GetBuilder<LoginHandler>(builder: (_) {
              return FutureBuilder(
                future:
                    loginHandler.selectMyinfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  } else {
                    return Obx(() {
                      final result = loginHandler.mypageUserInfo;
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildProfileSection(context, result),
                            _buildInfoSection(result),
                            const Divider(
                                color: Colors.grey,
                                thickness: 1,
                                indent: 16,
                                endIndent: 16),
                            _buildActionButtons(context, loginHandler, result),
                          ],
                        ),
                      );
                    });
                  }
                },
              );
            })
          : const Center(
              child: Text(
                '로그인이 필요합니다.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
    );
  }

_buildProfileSection(BuildContext context, List result) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 20),
    color: Colors.green.shade50,
    child: Center(
      child: Column(
        children: [
          FutureBuilder<String?>(
            future: loginHandler.fetchAccessToken(), // 비동기적으로 토큰 가져오기
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 로딩 중 상태
                return const CircleAvatar(
                  radius: 60,
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                // 오류 발생 시
                return const CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.error),
                );
              }

              final accessToken = snapshot.data;

              return CachedNetworkImage(
                imageUrl: "${loginHandler.server}/mypage/view/${result[0].image}",
                httpHeaders: {
                  'Authorization': 'Bearer $accessToken', // 가져온 토큰 설정
                },
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 60,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => const CircleAvatar(
                  radius: 60,
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.error),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            result[0].name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}



  _buildInfoSection(List result) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '회원 정보',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem('이름', result[0].name),
                  const SizedBox(height: 8),
                  _buildInfoItem('이메일', result[0].id!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildInfoItem(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  _buildActionButtons(
      BuildContext context, LoginHandler loginHandler, List result) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.logout,
            label: '로그아웃',
            onPressed: () => showDialog(loginHandler),
            color: Colors.red,
          ),
          _buildActionButton(
            icon: Icons.edit,
            label: '내정보 수정',
            onPressed: () {
              Get.to(MyinfoUpdate(), arguments: result[0].id)!.then(
                (value) =>
                    loginHandler.selectMyinfo(),
              );
            },
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  showDialog(LoginHandler loginHandler) {
    Get.defaultDialog(
      title: "로그아웃",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      middleText: '로그아웃 하시겠습니까?',
      textConfirm: "확인",
      textCancel: "취소",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.black,
      buttonColor: Colors.lightGreen,
      onConfirm: () async {
        await loginHandler.signOut();
        Get.offAll(() => Navigation());
      },
    );
  }
}

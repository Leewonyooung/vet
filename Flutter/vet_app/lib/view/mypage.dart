import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/myinfo_update.dart';
import 'package:vet_app/view/navigation.dart';
import 'package:vet_app/vm/login_handler.dart';

class Mypage extends StatelessWidget {
  const Mypage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginHandler loginHandler = Get.find();
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
                    loginHandler.selectMyinfo(loginHandler.getStoredEmail()),
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
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                  'http://127.0.0.1:8000/mypage/view/${result[0].image}'),
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
                    loginHandler.selectMyinfo(loginHandler.getStoredEmail()),
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

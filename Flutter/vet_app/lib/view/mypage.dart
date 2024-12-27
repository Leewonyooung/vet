import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/myinfo_update.dart';
import 'package:vet_app/view/navigation.dart';
import 'package:vet_app/vm/login_handler.dart';

class Mypage extends StatelessWidget {
  Mypage({super.key});
  final LoginHandler loginHandler = Get.find();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: screenWidth * 0.05,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      body: loginHandler.isLoggedIn()
          ? GetBuilder<LoginHandler>(builder: (_) {
              return FutureBuilder(
                future: loginHandler.selectMyinfo(),
                builder: (context, snapshot) =>  Obx(() {
                  final result = loginHandler.mypageUserInfo;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProfileSection(context, result, screenWidth),
                        _buildInfoSection(result, screenWidth),
                        Divider(
                          color: Colors.grey,
                          thickness: 1,
                          indent: screenWidth * 0.05,
                          endIndent: screenWidth * 0.05,
                        ),
                        _buildActionButtons(
                            context, loginHandler, result, screenWidth),
                      ],
                    ),
                  );
                }
                            ),
              );
          }
    ):const Center(child: CircularProgressIndicator(),));
  }

  Widget _buildProfileSection(
    BuildContext context, List result, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.05),
      color: Colors.green.shade50,
      child: Center(
        child: Column(
          children: [
            CachedNetworkImage(
                  imageUrl:
                      "${loginHandler.server}/mypage/view/${result[0].image}",
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: screenWidth * 0.15,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => CircleAvatar(
                    radius: screenWidth * 0.15,
                    child: const CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: screenWidth * 0.15,
                    child: const Icon(Icons.error),
                  ),
                ),
                  SizedBox(height: screenWidth * 0.04),
            Text(
              result[0].name,
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]
        )
      )
    );
  }

  Widget _buildInfoSection(List result, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '회원 정보',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem('이름', result[0].name, screenWidth),
                  SizedBox(height: screenWidth * 0.02),
                  _buildInfoItem('이메일', result[0].id!, screenWidth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, double screenWidth) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, LoginHandler loginHandler,
      List result, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.logout,
            label: '로그아웃',
            onPressed: () => showDialog(loginHandler),
            color: Colors.red,
            screenWidth: screenWidth,
          ),
          _buildActionButton(
            icon: Icons.edit,
            label: '내정보 수정',
            onPressed: () {
              Get.to(MyinfoUpdate(), arguments: result[0].id)!.then(
                (value) => loginHandler.selectMyinfo(),
              );
            },
            color: Colors.green,
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required double screenWidth,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: screenWidth * 0.05),
      label: Text(
        label,
        style: TextStyle(fontSize: screenWidth * 0.045),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.035,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
      ),
    );
  }

  void showDialog(LoginHandler loginHandler) {
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

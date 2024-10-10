import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/myinfo_update.dart';
import 'package:vet_app/view/pet_info.dart';
import 'package:vet_app/vm/login_handler.dart';

class Mypage extends StatelessWidget {
  const Mypage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginHandler loginHandler = Get.put(LoginHandler());
    String userid = loginHandler.getStoredEmail();
    loginHandler.selectMyinfo(userid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: GetBuilder<LoginHandler>(
        builder: (_) {
          if (loginHandler.mypageUserInfo.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final result = loginHandler.mypageUserInfo[0];
              return
              Obx(
                () {
                return Center(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            loginHandler.mypageUserInfo[0].image,
                            width: 100,
                            height: 100,
                          ),
                          Text(result.name),
                        ],
                      ),
                      Text(result.id!),
                      const Divider(
                        color: Colors.grey, // 선의 색상
                        thickness: 1, // 선의 두께
                        indent: 16, // 왼쪽 여백
                        endIndent: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Get.to(const PetInfo());
                              },
                              child: const Column(
                                children: [Icon(Icons.pets), Text('반려동물')],
                              )),
                          ElevatedButton(
                              onPressed: () {
                                Get.to(
                                  MyinfoUpdate(), 
                                  arguments: [
                                      result.id,
                                      result.name,
                                      result.image
                                ])!.then((value) => loginHandler.selectMyinfo(userid));
                              },
                              child: const Column(
                                children: [
                                  Icon(Icons.account_circle),
                                  Text('내정보 수정')
                                ],
                              )),
                        ],
                      )
                    ],
                  ),
                );
                }
              );
              }
          }
            )
    );
}
}

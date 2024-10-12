import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/myinfo_update.dart';
import 'package:vet_app/vm/login_handler.dart';

class Mypage extends StatelessWidget {
  const Mypage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginHandler loginHandler = Get.put(LoginHandler());
    return Scaffold(
        appBar: AppBar(
          title: const Text('마이페이지'),
        ),
        body: GetBuilder<LoginHandler>(builder: (_) {
          return FutureBuilder(
              future: loginHandler.selectMyinfo(loginHandler.getStoredEmail()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("${snapshot.error}"),
                  );
                } else {
                  return Obx(
                    () {
                      final result = loginHandler.mypageUserInfo[0];
                      return Center(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.network(
                                    'http://127.0.0.1:8000/mypage/view/${result.image}'),
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
                                      // Get.to(const PetInfo());
                                    },
                                    child: const Column(
                                      children: [
                                        Icon(Icons.pets),
                                        Text('반려동물')
                                      ],
                                    )),
                                ElevatedButton(
                                    onPressed: () {
                                      Get.to(
                                        MyinfoUpdate(),
                                        arguments: result.id,
                                      )!
                                          .then((value) => loginHandler
                                              .selectMyinfo(loginHandler
                                                  .getStoredEmail()));
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
                    },
                  );
                }
              });
        }));
  }
}

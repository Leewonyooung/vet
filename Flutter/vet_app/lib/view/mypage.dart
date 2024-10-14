import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_app/view/myinfo_update.dart';
import 'package:vet_app/view/navigation.dart';
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
        body: loginHandler.isLoggedIn()?
        GetBuilder<LoginHandler>(builder: (_) {
          return FutureBuilder(
              future: loginHandler.selectMyinfo(loginHandler.getStoredEmail()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return  Center(
                    child: Text('${snapshot.error}'),
                  );
                } else {
                  return Obx(
                    () {
                      final result = loginHandler.mypageUserInfo;
                      return Center(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.network(
                                    'http://127.0.0.1:8000/mypage/view/${result[0].image}'),
                                Text(result[0].name),
                              ],
                            ),
                            Text(result[0].id!),
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
                                    onPressed: (){
                                    },
                                    child: const Column(
                                      children: [
                                        Icon(Icons.pets),
                                        Text('로그아웃')
                                      ],
                                    )),
                                ElevatedButton(
                                    onPressed: () {
                                      Get.to(
                                        MyinfoUpdate(),
                                        arguments: result[0].id,
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
        })
        : const Center(child: Text('로그인이 필요합니다.'),)
        );
  }

  //ff
  showDialog(LoginHandler loginHandler) {
    Get.defaultDialog(
        title: "로그아웃",
        middleText: '로그아웃 하시겠습니까?',
        onCancel: () => Get.back(),
        onConfirm: () async {
          await loginHandler.signOut();
          Get.offAll(() => Navigation());
        });
  }
}

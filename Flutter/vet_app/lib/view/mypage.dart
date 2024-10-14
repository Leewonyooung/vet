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
          title: const Text('마이페이지',style: TextStyle(fontSize: 26),),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    'http://127.0.0.1:8000/mypage/view/${result[0].image}',
                                    width: MediaQuery.of(context).size.width/1.5,  
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width/1.15,
                                height: MediaQuery.of(context).size.height/20,
                                child: const Text(
                                  '회원 정보',
                                  style:TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              width: MediaQuery.of(context).size.width/1.1,
                              height: MediaQuery.of(context).size.height/5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).colorScheme.onSecondary
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('이름: ${result[0].name}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Padding(
                                          padding:  EdgeInsets.only(top:6.0),
                                          child:  Text('이메일: ',
                                            style:  TextStyle(
                                            fontSize: 22,
                                          ),),
                                        ),
                                        Text(result[0].id!,
                                        style: const TextStyle(fontSize: 22),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

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
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(
                                      MediaQuery.of(context).size.width/3, 
                                      MediaQuery.of(context).size.height/14
                                    ),
                                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer
                                  ),
                                    onPressed: (){
                                      showDialog(loginHandler);
                                    },
                                    child: const Column(
                                      children: [
                                        Icon(Icons.pets, size: 35,),
                                        Text('로그아웃', style:  TextStyle(fontSize: 16),)
                                      ],
                                    )),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(
                                      MediaQuery.of(context).size.width/3, 
                                      MediaQuery.of(context).size.height/14
                                    ),
                                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer
                                  ),
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
                                        Icon(Icons.account_circle,size: 35,),
                                        Text('내정보 수정',style: TextStyle(fontSize: 16),)
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
  showDialog(LoginHandler loginHandler){
    Get.defaultDialog(
      title: "로그아웃",
      middleText: '로그아웃 하시겠습니까?',
      onCancel: () => (),
      onConfirm: ()async{ 
        await loginHandler.signOut();
        Get.offAll(()=>Navigation());
        }
    );
  }
}

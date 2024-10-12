import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vet_app/view/chat_room.dart';
import 'package:vet_app/view/clinic_search.dart';
import 'package:vet_app/view/favorite.dart';
import 'package:vet_app/view/login.dart';
import 'package:vet_app/view/mypage.dart';
import 'package:vet_app/view/pet_info.dart';
import 'package:vet_app/view/pet_register.dart';
import 'package:vet_app/view/query_reservation.dart';
import 'package:vet_app/view/reservation.dart';
import 'package:vet_app/vm/chat_handler.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/pet_handler.dart';

class Navigation extends StatelessWidget {
  Navigation({super.key});

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  final LoginHandler loginHandler = Get.put(LoginHandler());
  final PetHandler petHandler = Get.put(PetHandler());
  final ChatsHandler chatsHandler = Get.put(ChatsHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _screens(),
        items: _items(),
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardAppears: true,
        popBehaviorOnSelectedNavBarItemPress: PopBehavior.none,
        padding: const EdgeInsets.only(top: 10),
        backgroundColor: Colors.grey.shade900,
        isVisible: true,
        onItemSelected: (index) {
          if (index != 0 && index != 1 && !loginHandler.isLoggedIn()) {
            Get.to(() => Login());
          }
        },
        animationSettings: const NavBarAnimationSettings(
          navBarItemAnimation: ItemAnimationSettings(
            duration: Duration(milliseconds: 400),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimationSettings(
            animateTabTransition: false,
          ),
        ),
        confineToSafeArea: true,
        navBarHeight: 60,
        navBarStyle: NavBarStyle.style8,
      ),
    );
  }

  List<Widget> _screens() {
    return [
      Scaffold(
        appBar: AppBar(
          title: const Text('멍스파인더'),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                if (loginHandler.isLoggedIn()) {
                  Get.to(Favorite());
                } else {
                  Get.to(Login());
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                if (loginHandler.isLoggedIn()) {
                  Get.to(const Mypage());
                } else {
                  Get.to(Login());
                }
              },
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        body: Obx(() {
          return Container(
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue.shade100,
                  ),
                  child: const Center(
                    child: Text(
                      '전문가 상담\n우리집 강아지 고민\n지금 무료 상담 받으세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildButton(
                        icon: Icons.local_hospital,
                        text: '긴급 예약',
                        color: Colors.red.shade400,
                        onTap: () {
                          if (loginHandler.isLoggedIn()) {
                            Get.to(Reservation());
                          } else {
                            Get.to(Login());
                          }
                        },
                      ),
                      _buildButton(
                        icon: Icons.assignment,
                        text: '예약 내역',
                        color: Colors.amber.shade400,
                        onTap: () {
                          if (loginHandler.isLoggedIn()) {
                            Get.to(() => const QueryReservation());
                          } else {
                            Get.to(Login());
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                petHandler.pets.isEmpty
                    ? _buildRegisterBanner()
                    : _buildPetInfoList()
              ],
            ),
          );
        }),
      ),
      ClinicSearch(),
      const QueryReservation(),
      ChatRoom(),
      const Mypage(),
    ];
  }

  Widget _buildRegisterBanner() {
    return GestureDetector(
      onTap: () {
        if (loginHandler.isLoggedIn()) {
          Get.to(const PetRegister());
        } else {
          Get.to(Login());
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.pets, size: 40),
            SizedBox(width: 10),
            Text(
              '내가 키우는 반려동물을 등록해 보세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetInfoList() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: petHandler.pets.length + 1, // 반려동물 수에 추가 버튼 포함
        itemBuilder: (context, index) {
          if (index == petHandler.pets.length) {
            // 반려동물 등록 버튼 추가
            return GestureDetector(
              onTap: () async {
                // PetRegister 페이지에서 돌아올 때 결과 확인
                var result = await Get.to(() => const PetRegister());

                // 등록 후 화면 갱신
                if (result == true) {
                  // 반려동물 정보 다시 로드
                  String userId = loginHandler.getStoredEmail();
                  petHandler.fetchPets(userId);
                }
              },
              child: const Card(
                elevation: 4,
                margin: EdgeInsets.all(8),
                child: SizedBox(
                  width: 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 40),
                      SizedBox(height: 10),
                      Text(
                        '반려동물 등록',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // 기존 반려동물 정보 표시
          final pet = petHandler.pets[index];

          return GestureDetector(
            onTap: () {
              Get.to(() => PetInfo(pet: pet));
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.all(10),
                width: 360,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지 불러오기 (왼쪽)

                    Image.network(
                      'http://127.0.0.1:8000/pet/uploads/${pet.image}',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.error,
                          size: 150,
                        ); // 이미지 로드 실패 시
                      },
                    ),
                    const SizedBox(width: 10), // 이미지와 텍스트 사이 간격
                    // 텍스트 정보 (오른쪽)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text('종류: ${pet.speciesType}'),
                          const SizedBox(height: 5),
                          Text('세부종류: ${pet.speciesCategory}'),
                          const SizedBox(height: 5),
                          Text('성별: ${pet.gender}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<PersistentBottomNavBarItem> _items() {
    return [
      _btnItem(
        title: "홈",
        icon: Icons.home_filled,
        activeColor: Colors.deepPurple,
      ),
      _btnItem(
        title: "검색",
        icon: Icons.search,
        activeColor: Colors.deepOrange,
      ),
      _btnItem(
        title: "예약내역",
        icon: Icons.calendar_today,
        activeColor: Colors.amber,
      ),
      _btnItem(
        title: "채팅",
        icon: Icons.chat,
        activeColor: Colors.green,
      ),
      _btnItem(
        title: "마이페이지",
        icon: Icons.person,
        activeColor: Colors.blue,
      ),
    ];
  }

  PersistentBottomNavBarItem _btnItem({
    required String title,
    required IconData icon,
    required Color activeColor,
  }) {
    return PersistentBottomNavBarItem(
      title: title,
      icon: Icon(icon),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      activeColorPrimary: activeColor,
      inactiveColorPrimary: const Color.fromRGBO(195, 195, 195, 1),
      activeColorSecondary: Colors.white,
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

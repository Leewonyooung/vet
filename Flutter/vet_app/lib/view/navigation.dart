import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vet_app/view/chat.dart';
import 'package:vet_app/view/clinic_search.dart';
import 'package:vet_app/view/favorite.dart';
import 'package:vet_app/view/mypage.dart';
import 'package:vet_app/view/pet_register.dart';
import 'package:vet_app/view/query_reservation.dart';

class Navigation extends StatelessWidget {
  Navigation({super.key});

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

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
                Get.to(const Favorite());
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Get.to(const Mypage());
              },
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 10),
              // 상단 배너
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
              // 긴급 예약 및 예약 내역 버튼
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
                        // 긴급 예약 기능
                      },
                    ),
                    _buildButton(
                      icon: Icons.assignment,
                      text: '예약 내역',
                      color: Colors.amber.shade400,
                      onTap: () {
                        // 예약 내역 확인
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 반려동물 등록
              GestureDetector(
                onTap: () {
                  Get.to(const PetRegister());
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
              ),
            ],
          ),
        ),
      ),
      const ClinicSearch(),
      const QueryReservation(),
      const Chat(),
      const Mypage(),
    ];
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

  // --- Functions ---
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
} // end

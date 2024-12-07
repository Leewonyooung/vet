import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:vet_app/model/pet.dart';
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
import 'package:vet_app/vm/favorite_handler.dart';
import 'package:vet_app/vm/login_handler.dart';
import 'package:vet_app/vm/pet_handler.dart';
import 'package:vet_app/vm/reservation_handler.dart';

class Navigation extends StatelessWidget {
  Navigation({super.key});

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  final LoginHandler loginHandler = Get.put(LoginHandler(), permanent: true);
  final PetHandler petHandler = Get.put(PetHandler(), permanent: true);
  final ChatsHandler chatsHandler = Get.put(ChatsHandler());
  final FavoriteHandler favoriteHandler = Get.put(FavoriteHandler(), permanent: true);

  final vmHnadler = Get.put(ReservationHandler());
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
          if (index == 1) {
            favoriteHandler.searchbarController.clear();
            favoriteHandler.getAllClinic();
          }
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
            title: const Text(
              '멍스파인더',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green.shade400,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (loginHandler.isLoggedIn()) {
                    Get.to(() => Favorite());
                  } else {
                    Get.to(() => Login());
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (loginHandler.isLoggedIn()) {
                    Get.to(() => Mypage());
                  } else {
                    Get.to(() => Login());
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildBanner(),
                const SizedBox(height: 30),
                _buildQuickActions(),
                const SizedBox(height: 30),
                _buildPetSection(),
              ],
            ),
          )),
      ClinicSearch(),
      QueryReservation(),
      ChatRoom(),
      Mypage(),
    ];
  }

  _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          '전문가 상담\n우리집 강아지 고민\n지금 무료 상담 받으세요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: Icons.local_hospital,
            text: '긴급 예약',
            color: Colors.red.shade400,
            onTap: () {
              if (loginHandler.isLoggedIn()) {
                Get.to(() => Reservation());
              } else {
                Get.to(() => Login());
              }
            },
          ),
          _buildActionButton(
            icon: Icons.assignment,
            text: '예약 내역',
            color: Colors.amber.shade400,
            onTap: () {
              if (loginHandler.isLoggedIn()) {
                Get.to(() => QueryReservation());
              } else {
                Get.to(() => Login());
              }
            },
          ),
        ],
      ),
    );
  }

  _buildActionButton({
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
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _buildPetSection() {
    return Obx(() {
      if (petHandler.pets.isEmpty) {
        return _buildRegisterBanner();
      }
      return _buildPetList();
    });
  }

  _buildRegisterBanner() {
    return GestureDetector(
      onTap: () async {
        if (loginHandler.isLoggedIn()) {
          var result = await Get.to(() => PetRegister());
          if (result == true) {
            String userId = loginHandler.getStoredEmail();
            await petHandler.fetchPets(userId);
          }
        } else {
          Get.to(() => Login());
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.pets,
              size: 40,
              color: Colors.grey[900],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '내가 키우는 반려동물을 등록해 보세요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildPetList() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: petHandler.pets.length + 1,
        itemBuilder: (context, index) {
          if (index == petHandler.pets.length) {
            return _buildAddPetCard();
          }
          return _buildPetCard(petHandler.pets[index]);
        },
      ),
    );
  }

  _buildPetCard(Pet pet) {
    return GestureDetector(
      onTap: () => Get.to(() => PetInfo(pet: pet)),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          border: Border.all(
            color: Colors.green.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  '${pet.image}',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error,
                    size: 120,
                  ),
                ),
              ),
            ),
            Container(
              height: 2,
              color: Colors.green.shade300,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    pet.speciesCategory,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildAddPetCard() {
    return GestureDetector(
      onTap: () async {
        var result = await Get.to(() => PetRegister());
        if (result == true) {
          String userId = loginHandler.getStoredEmail();
          await petHandler.fetchPets(userId);
        }
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.green.shade50,
          border: Border.all(
            color: Colors.green.shade200,
            width: 2,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 40,
              color: Colors.green,
            ),
            SizedBox(height: 8),
            Text(
              '반려동물 등록',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PersistentBottomNavBarItem> _items() {
    return [
      _buildNavBarItem(
        "홈",
        Icons.home_filled,
      ),
      _buildNavBarItem(
        "검색",
        Icons.search,
      ),
      _buildNavBarItem(
        "예약내역",
        Icons.calendar_today,
      ),
      _buildNavBarItem(
        "채팅",
        Icons.chat,
      ),
      _buildNavBarItem(
        "마이페이지",
        Icons.person,
      ),
    ];
  }

  PersistentBottomNavBarItem _buildNavBarItem(String title, IconData icon) {
    return PersistentBottomNavBarItem(
      title: title,
      icon: Icon(icon),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      activeColorPrimary: Colors.white,
      inactiveColorPrimary: Colors.grey,
    );
  }
}

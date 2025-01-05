import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:vet_app/vm/token_access.dart';

class Navigation extends StatelessWidget {
  Navigation({super.key});
  final TokenAccess token = Get.put(TokenAccess());
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  final LoginHandler loginHandler = Get.put(LoginHandler(), permanent: true);
  final PetHandler petHandler = Get.put(PetHandler(), permanent: true);
  final ChatsHandler chatsHandler = Get.put(ChatsHandler());
  final FavoriteHandler favoriteHandler =
      Get.put(FavoriteHandler(), permanent: true);
  final vmHandler = Get.put(ReservationHandler());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _screens(screenWidth, screenHeight),
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
        navBarHeight: screenHeight * 0.07,
        navBarStyle: NavBarStyle.style8,
      ),
    );
  }

  List<Widget> _screens(double screenWidth, double screenHeight) {
    return [
      Scaffold(
        appBar: AppBar(
          title: Text(
            '멍스파인더',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.05,
            ),
          ),
          backgroundColor: Colors.green.shade400,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white),
              iconSize: screenWidth * 0.07,
              onPressed: () async {
                if (loginHandler.isLoggedIn()) {
                  await favoriteHandler
                      .getFavoriteClinics(loginHandler.box.read('userEmail'));
                  Get.to(() => Favorite());
                } else {
                  Get.to(() => Login());
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              iconSize: screenWidth * 0.07,
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
              SizedBox(height: screenHeight * 0.03),
              _buildBanner(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.03),
              _buildQuickActions(screenWidth),
              SizedBox(height: screenHeight * 0.03),
              _buildPetSection(screenWidth),
            ],
          ),
        ),
      ),
      ClinicSearch(),
      QueryReservation(),
      ChatRoom(),
      Mypage(),
    ];
  }

  Widget _buildBanner(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      height: screenHeight * 0.2,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: Center(
        child: Text(
          '전문가 상담\n우리집 강아지 고민\n지금 무료 상담 받으세요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
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
            screenWidth: screenWidth,
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
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: screenWidth * 0.2,
            width: screenWidth * 0.2,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: screenWidth * 0.08,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSection(double screenWidth) {
    return Obx(() {
      if (petHandler.pets.isEmpty) {
        return _buildRegisterBanner(screenWidth);
      }
      return _buildPetList(screenWidth);
    });
  }

  Widget _buildRegisterBanner(double screenWidth) {
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
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
              size: screenWidth * 0.12,
              color: Colors.grey[900],
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Text(
                '내가 키우는 반려동물을 등록해 보세요',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
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

  Widget _buildPetList(double screenWidth) {
    return Container(
      height: screenWidth * 0.5,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            petHandler.pets.length + 1,
            (index) {
              if (index == petHandler.pets.length) {
                return _buildAddPetCard(screenWidth);
              }
              return _buildPetCard(petHandler.pets[index], screenWidth);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(Pet pet, double screenWidth) {
    return GestureDetector(
      onTap: () => Get.to(() => PetInfo(pet: pet)),
      child: Container(
        width: screenWidth * 0.4,
        margin: EdgeInsets.only(right: screenWidth * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
            Container(
              height: screenWidth * 0.3,
              width: screenWidth * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(screenWidth * 0.04),
                ),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(screenWidth * 0.04),
                ),
                child: CachedNetworkImage(
                  imageUrl: pet.image!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
            Divider(color: Colors.green.shade300, height: screenWidth * 0.01),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                  Text(
                    pet.speciesCategory,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.035,
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

  Widget _buildAddPetCard(double screenWidth) {
    return GestureDetector(
      onTap: () async {
        var result = await Get.to(() => PetRegister());
        if (result == true) {
          String userId = loginHandler.getStoredEmail();
          await petHandler.fetchPets(userId);
        }
      },
      child: Container(
        width: screenWidth * 0.4,
        margin: EdgeInsets.only(right: screenWidth * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          color: Colors.green.shade50,
          border: Border.all(
            color: Colors.green.shade200,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: screenWidth * 0.1,
              color: Colors.green,
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              '반려동물 등록',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
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
      _buildNavBarItem("홈", Icons.home_filled),
      _buildNavBarItem("검색", Icons.search),
      _buildNavBarItem("예약내역", Icons.calendar_today),
      _buildNavBarItem("채팅", Icons.chat),
      _buildNavBarItem("마이페이지", Icons.person),
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

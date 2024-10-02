import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Navigation extends StatelessWidget {
  Navigation({super.key});

  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
        
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
      );
  }
   List<Widget> _screens() {
    return [
      Scaffold(
        body: Container(
          color: Colors.white,
          child: const Center(child: Text('First Screen')),
        ),
      ),
      Container(
        color: Colors.white,
        child: const Center(child: Text('Second Screen')),
      ),
      Container(
        color: Colors.white,
        child: const Center(child: Text('Third Screen')),
      ),
      Container(
        color: Colors.white,
        child: const Center(child: Text('Fourth Screen')),
      ),
      Container(
        color: Colors.white,
        child: const Center(child: Text('Fifth Screen')),
      ),
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
          icon: Icons.add_box_rounded,
          activeColor: Colors.deepOrange),
      _btnItem(
        title: "예약내역",
        icon: Icons.settings,
        activeColor: Colors.amber,
      ),
      _btnItem(
        title: "채팅",
        icon: Icons.settings,
        activeColor: Colors.amber,
      ),
      _btnItem(
        title: "마이페이지",
        icon: Icons.settings,
        activeColor: Colors.amber,
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
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_tab/view/chat_room_view.dart';
import 'package:vet_tab/view/clinic_reservation.dart';
import 'package:vet_tab/vm/tab_vm.dart';

class RailHome extends StatelessWidget {
  RailHome({super.key});
  final TabVm controller = Get.put(TabVm());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '병원 관리',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
      ),
      body: Obx(
        () => Row(
          children: [
            NavigationRail(
              backgroundColor: const Color.fromRGBO(241, 239, 239, 1.0),
              selectedIndex: controller.currentScreenIndex.value,
              onDestinationSelected: (int index) {
                controller.tabController.index = index;
                controller.currentScreenIndex.value = index;
              },
              labelType: NavigationRailLabelType.selected,
              selectedIconTheme: const IconThemeData(color: Colors.blueGrey),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.grey,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  selectedIcon: Icon(Icons.home_filled),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: Text('Reservation'),
                ),
              ],
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _buildSelectedScreen(controller.currentScreenIndex.value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedScreen(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return ChatRoomView();
      case 1:
        return ClinicReservation();
      default:
        return Container();
    }
  }
}

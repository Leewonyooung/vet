import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vet_tab/view/chat_room_view.dart';
import 'package:vet_tab/view/clinic_reservation.dart';
import 'package:vet_tab/view/mgt_home.dart';
import 'package:vet_tab/view/mgt_species_add.dart';
import 'package:vet_tab/vm/tab_vm.dart';

class RailHome extends StatelessWidget {
  RailHome({super.key});
  final TabVm controller = Get.put(TabVm());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:Obx(()=> Row(
        children: [
          NavigationRail(
                backgroundColor: const Color.fromRGBO(241, 239, 239, 1.0),
                selectedIndex: controller.currentScreenIndex.value,
                onDestinationSelected: (int index) {
                controller.tabController.index = index;
                },
                labelType: NavigationRailLabelType.selected,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    selectedIcon: Icon(Icons.home_filled),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.search),
                    selectedIcon: Icon(Icons.search),
                    label: Text('Search'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    selectedIcon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_month),
                    selectedIcon: Icon(Icons.calendar_month),
                    label: Text('Reservation'),
                  ),
                ],
              ),
            Expanded(
              child: Center(
                child: _buildSelectedScreen(controller.currentScreenIndex.value),
            ),
          ),
        ],
      ),
      )
    );
  }
  Widget _buildSelectedScreen(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return ChatRoomView();
      case 1:
        return const MgtHome();
      case 2:
        return const MgtSpeciesAdd();
      case 3:
        return ClinicReservation();
      default:
        return Container();
    }
  }
}
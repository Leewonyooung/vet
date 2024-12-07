import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabVm extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final RxInt currentScreenIndex = 0.obs;
  String server = 'https://port-0-fastapi-m473fdyf90368eeb.sel4.cloudtype.app';
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      currentScreenIndex.value = tabController.index;
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

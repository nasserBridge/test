import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MasterOnboardingController extends GetxController {
  static MasterOnboardingController get instance => Get.find();
  final pageChanger = PageController();
  RxInt currentPage = 0.obs;

  @override
  void onClose() {
    pageChanger.dispose();
    currentPage = 0.obs;
    super.onClose();
  }

  void backOnePage() {
    if (pageChanger.page != null && pageChanger.page! > 0) {
      pageChanger.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}

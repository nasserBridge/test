import 'package:bridgeapp/src/features/authentication/screens/onboarding/controllers/master_onboarding_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/repositories/sign_up_repo.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class EmailOnboardingController extends GetxController {
  static EmailOnboardingController get instance => Get.find();

  final emailTextEditor = TextEditingController();
  GlobalKey<FormState>? formkey = GlobalKey<FormState>();
  final _repo = Get.put(SignUpRepo());
  final _controller = Get.put(MasterOnboardingController());

  @override
  void onClose() {
    emailTextEditor.dispose();
    formkey = null;
    super.onClose();
  }

  /// Manually disposes this controller and unregisters it from GetX.
  ///
  /// This method is useful when the controller is not bound via typical
  /// GetBuilder lifecycle management and needs to be explicitly cleaned up.
  ///
  /// Steps:
  /// - Calls [dispose] to release internal resources
  /// - Checks if the controller is still registered with GetX
  /// - If so, calls [Get.delete] to remove the instance from memory
  void manuallyDispose() {
    if (Get.isRegistered<EmailOnboardingController>()) {
      Get.delete<EmailOnboardingController>();
    }
  }

  void submitEmail() {
    if (formkey != null &&
        formkey!.currentState != null &&
        formkey!.currentState!.validate()) {
      _repo.user.value.email = emailTextEditor.text.trim();
    }
    // Animate with smooth transition
    _controller.pageChanger.animateToPage(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}

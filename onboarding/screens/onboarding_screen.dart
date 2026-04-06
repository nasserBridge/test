import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/controllers/master_onboarding_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/email_form_body.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/onboarding_appbar.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/onboarding_navbar.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/password_form_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreenNew extends StatefulWidget {
  const OnboardingScreenNew({super.key});

  @override
  State<OnboardingScreenNew> createState() => _OnboardingScreenNewState();
}

class _OnboardingScreenNewState extends State<OnboardingScreenNew> {
  final _controller = Get.put(MasterOnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.customGreen,
        resizeToAvoidBottomInset: false,
        appBar: OnboardingAppBar(),
        body: onboardingBody(),
        bottomNavigationBar: OnboardingNavbar());
  }

  Widget onboardingBody() {
    return PageView.builder(
      controller: _controller.pageChanger,
      onPageChanged: (index) {
        _controller.currentPage.value = index;
      },
      itemCount: 2,
      physics: const NeverScrollableScrollPhysics(), // manual control only
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return EmailFormBody(key: ValueKey('email_form'));
          case 1:
            return PasswordFormBody(key: ValueKey('password_form'));
          default:
            return const SizedBox.shrink(); // fallback, shouldn't be reached
        }
      },
    );
  }
}

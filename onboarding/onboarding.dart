import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/controllers/onboarding_controller.dart';
import 'package:bridgeapp/src/features/authentication/controllers/timer_controller.dart';
import 'package:bridgeapp/src/common_widgets/popup_yes_no.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/consent.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/mail_verification.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/phone_mfa.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/steps_complete.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final _controller = Get.put(OnBoardingController());
  late AppLifecycleController _appLifecycleController;

  @override
  void initState() {
    super.initState();

    // Set up app lifecycle timeout handling
    _appLifecycleController = AppLifecycleController(
      onTimeout: () {
        _controller.logoutOnboarding();
      },
    );

    // Check onboarding progress on screen load
    _controller.checkprogress();
  }

  @override
  void dispose() {
    _appLifecycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            PopupYesNo.showInfoDialog(
              context,
              mainText: 'Are you sure you want to logout?',
              onYesPressed: () => _controller.logoutOnboarding(),
            );
          },
          icon: Transform.rotate(
            angle: math.pi, // Rotates the icon 180 degrees
            child: const Icon(Icons.logout),
          ),
        ),
        title: Image.asset(
          'assets/images/greenBridge.png',
          height: Scale.x(45),
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _controller.checkprogress();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(
            Scale.x(30), screenHeight * .03, Scale.x(30), 0),
        child: ListView(
          children: [
            Text(
              "Onboarding Process!",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.navy,
                fontFamily: 'Raleway',
                fontSize: Scale.x(25),
                fontWeight: FontWeight.bold,
                letterSpacing: Scale.x(2.5),
              ),
            ),
            SizedBox(height: screenHeight * Scale.x(0.03)),

            // Email Verification Step
            Obx(() => StepsComplete(
                  onboardingstep: 'E-mail Verification',
                  onboardingstatus: _controller.emailStatus.value,
                )),
            Obx(() => _controller.onboardingStep.value == 'level1'
                ? const MailVerification()
                : const SizedBox(width: 0)),

            // Multi-Factor Authentication Step
            Obx(() => StepsComplete(
                  onboardingstep: 'Multi-Factor Auth',
                  onboardingstatus: _controller.mfaStatus.value,
                )),
            Obx(() => _controller.onboardingStep.value == 'level2'
                ? PhoneMFA()
                : const SizedBox(width: 0)),

            // Disclosures Step
            Obx(() => StepsComplete(
                  onboardingstep: 'Disclosures',
                  onboardingstatus: _controller.disclosuresStatus.value,
                )),
            Obx(() => _controller.onboardingStep.value == 'level3'
                ? const ConsentScreen()
                : const SizedBox(width: 0)),

            Container(
              width: double.infinity,
              height: Scale.x(1),
              color: AppColors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/image_strings.dart';
import 'package:bridgeapp/src/features/authentication/controllers/login_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/splash_screen/splash_screen.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import 'package:get/get.dart';

class OTPVerification extends StatelessWidget {
  final _controller = Get.put(LoginController());

  OTPVerification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.to(() => SplashScreen());
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
        ),
        title: const Image(image: AssetImage(logoImageV1)),
        centerTitle: true,
        actions: const [
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: Scale.x(30),
          ),
          Text("Verify the 6-digit code sent to you registered number.",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: AppColors.navy,
                fontFamily: 'Raleway',
                fontSize: Scale.x(13),
                fontWeight: FontWeight.w600,
                letterSpacing: Scale.x(2.5),
              )),
          SizedBox(height: Scale.x(30)),
          OtpTextField(
            numberOfFields: 6,
            fieldWidth: Scale.x(20),
            showFieldAsBox: false,
            fillColor: Colors.black.withValues(alpha: .1),
            filled: false,
            onSubmit: (code) {
              _controller.verifyMfaComplete(code);
            },
          ),
          SizedBox(height: Scale.x(60)),
          GestureDetector(
            onTap: () => _controller.resendMfaCode(),
            child: const Text(
              "Resend Code",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: Scale.x(80)),
        ],
      ),
    );
  }
}

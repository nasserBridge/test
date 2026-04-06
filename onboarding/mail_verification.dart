import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/controllers/onboarding_controller.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//This page was set to a statafull widget because placing
//the sendverificationEmail under widget build results in an infinite loop.

class MailVerification extends StatefulWidget {
  const MailVerification({super.key});

  @override
  State<MailVerification> createState() => _MailVerificationState();
}

class _MailVerificationState extends State<MailVerification> {
  final _controller = Get.put(OnBoardingController());
  final String? _email = FirebaseAuth.instance.currentUser?.email;
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    _controller.sendVerificationEmail();
  }

  @override
  Widget build(BuildContext context) {
    // _controller.sendVerificationEmail();

    return Column(
      children: [
        SizedBox(height: Scale.x(30)),
        Text("Please verify the email link sent to: $_email",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontFamily: 'Raleway',
              fontSize: Scale.x(16),
              fontWeight: FontWeight.w600,
              letterSpacing: Scale.x(2.5),
            )),
        SizedBox(height: Scale.x(45)),
        const Text("Click 'Continue' after verifying your email.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Raleway',
              color: AppColors.navy,
            )),
        SizedBox(height: Scale.x(10)),
        ElevatedButton(
            style: ButtonStyle(
              fixedSize:
                  WidgetStateProperty.all(Size(Scale.x(210), Scale.x(15))),
              backgroundColor:
                  WidgetStateColor.resolveWith((states) => AppColors.green),
              foregroundColor:
                  WidgetStateColor.resolveWith((states) => AppColors.white),
              overlayColor:
                  WidgetStateColor.resolveWith((states) => AppColors.navy),
            ),
            onPressed: () {
              setState(() => isloading = !isloading);
              _controller.manuallyCheckEmailVerificationStatus();
              setState(() => isloading = !isloading);
            },
            child: isloading == true
                ? const CircularProgressIndicator.adaptive()
                : Text('Continue',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w600,
                      letterSpacing: Scale.x(1.5),
                    ))),
        SizedBox(height: Scale.x(30)),
        GestureDetector(
          onTap: () => _controller.sendVerificationEmail(),
          child: const Text(
            "Resend Verification",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: Scale.x(45)),
      ],
    );
  }
}

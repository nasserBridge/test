import 'package:bridgeapp/src/common_widgets/otp_textfield.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/controllers/onboarding_controller.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneMFA extends StatefulWidget {
  const PhoneMFA({super.key});

  @override
  State<PhoneMFA> createState() => _PhoneMFAState();
}

class _PhoneMFAState extends State<PhoneMFA> {
  final _controller = Get.put(OnBoardingController());
  String? _onChangeCode;
  bool _isLoadingVerify = false;
  bool _isLoadingSendCode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: Scale.x(30),
        ),
        Text("Please enter the 6-digit code sent to your registered number",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: AppColors.navy,
              fontFamily: 'Raleway',
              fontSize: Scale.x(16),
              fontWeight: FontWeight.w600,
              letterSpacing: Scale.x(2.5),
            )),
        SizedBox(height: Scale.x(45)),
        MyOtpTextField(
          maxDigits: 6,
          fillColor: Colors.black.withValues(alpha: .1),
          filled: true,
          onSubmit: (code) async {
            if (code.length == 6) {
              setState(() {
                _isLoadingVerify = !_isLoadingVerify;
              });
              await _controller.checkPhoneVerification(code);
              setState(() {
                _isLoadingVerify = !_isLoadingVerify;
              });
            } else if (_onChangeCode == null) {
              _controller.incorrectInput();
            }
          },
        ),
        _isLoadingVerify == true
            ? Column(
                children: [
                  SizedBox(
                    height: Scale.x(20),
                  ),
                  const Text(
                    "Verifying...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : SizedBox.shrink(),
        SizedBox(height: Scale.x(45)),
        GestureDetector(
          onTap: () async {
            setState(() {
              _isLoadingSendCode = !_isLoadingSendCode;
            });

            await _controller.sendPhoneVerification();
            setState(() {
              _isLoadingSendCode = !_isLoadingSendCode;
            });
          },
          child: _isLoadingSendCode == true
              ? CircularProgressIndicator.adaptive()
              : Text(
                  "Resend Code",
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

import 'package:bridgeapp/src/common_widgets/otp_textfield.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/controllers/login_controller.dart';
import 'package:bridgeapp/src/features/authentication/controllers/timer_controller.dart';
import 'package:bridgeapp/src/common_widgets/popup_yes_no.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MfaLogin extends StatefulWidget {
  const MfaLogin({super.key});

  @override
  State<MfaLogin> createState() => _MfaLoginState();
}

class _MfaLoginState extends State<MfaLogin> {
  final _controller = Get.put(LoginController());
  late AppLifecycleController _appLifecycleController;
  // String? _onChangeCode;
  bool _isLoadingVerify = false;
  bool _isLoadingSendCode = false;

  @override
  void initState() {
    super.initState();
    _appLifecycleController = AppLifecycleController(
      onTimeout: () {
        // Handle timeout, e.g., log out the user
        _controller.logoutMfa();
      },
    );
  }

  @override
  void dispose() {
    _appLifecycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        MyOtpTextField(
          maxDigits: 6,
          fieldWidth: 20,
          showFieldAsBox: false,
          fillColor: Colors.black.withValues(alpha: .1),
          filled: false,
          onSubmit: (code) async {
            //print(!code.contains(_onChangeCode!));
            if (code.length == 6) {
              setState(() {
                _isLoadingVerify = !_isLoadingVerify;
              });
              if (AuthenticationRepository.instance.firebaseUser.value?.uid ==
                  'OKhWgOI8wSN34M3pODpDDAK8ULW2') {
                await Future.delayed(const Duration(seconds: 5));
                await _controller.verifyMfaComplete(code);
              } else {
                await _controller.verifyMfaComplete(code);
              }
              setState(() {
                _isLoadingVerify = !_isLoadingVerify;
              });
            } else {
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
        SizedBox(height: Scale.x(60)),
        GestureDetector(
          onTap: () async {
            setState(() {
              _isLoadingSendCode = !_isLoadingSendCode;
            });

            await _controller.resendMfaCode();
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
        SizedBox(height: Scale.x(80)),
        GestureDetector(
          onTap: () {
            PopupYesNo.showInfoDialog(
              context,
              mainText: 'Are you sure you want to log out?',
              onYesPressed: () => _controller.logoutMfa(),
            );
          },
          child: const Text(
            "Logout",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.green,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:bridgeapp/src/constants/colors.dart';
// import 'package:bridgeapp/src/features/authentication/controllers/login_controller.dart';
// import 'package:bridgeapp/src/features/authentication/controllers/timer_controller.dart';
// import 'package:bridgeapp/src/features/authentication/models/popup_yes_no.dart';
// import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:bridgeapp/src/features/authentication/screens/splash_screen/custom_otp_textfield.dart';
// import 'package:get/get.dart';

// class MfaLogin extends StatefulWidget {
//   const MfaLogin({super.key});

//   @override
//   State<MfaLogin> createState() => _MfaLoginState();
// }

// class _MfaLoginState extends State<MfaLogin> {
//   final _controller = Get.put(LoginController());
//   late AppLifecycleController _appLifecycleController;
//   String? _onChangeCode;
//   bool _isLoadingVerify = false;
//   bool _isLoadingSendCode = false;

//   @override
//   void initState() {
//     super.initState();
//     _appLifecycleController = AppLifecycleController(
//       onTimeout: () {
//         // Handle timeout, e.g., log out the user
//         _controller.logoutMfa();
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _appLifecycleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const SizedBox(
//           height: 30,
//         ),
//         const Text("Verify the 6-digit code sent to you registered number.",
//             textAlign: TextAlign.start,
//             style: TextStyle(
//               color: AppColors.navy,
//               fontFamily: 'Raleway',
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 2.5,
//             )),
//         const SizedBox(height: 30),
//         CustomOtpTextField(
//           numberOfFields: 6,
//           onCodeChanged: (value) async {
//             if (value.length == 6) {
//               setState(() {
//                 _onChangeCode = value;
//                 _isLoadingVerify = !_isLoadingVerify;
//               });
//               if (AuthenticationRepository.instance.firebaseUser.value?.uid ==
//                   'OKhWgOI8wSN34M3pODpDDAK8ULW2') {
//                 await Future.delayed(const Duration(seconds: 5));
//                 await _controller.verifyMfaComplete(value);
//               } else {
//                 await _controller.verifyMfaComplete(value);
//               }
//               setState(() {
//                 _isLoadingVerify = !_isLoadingVerify;
//               });
//             }
//           },
//           onSubmit: (code) async {
//             //print(!code.contains(_onChangeCode!));
//             if (code.length == 6) {
//               setState(() {
//                 _isLoadingVerify = !_isLoadingVerify;
//               });
//               if (AuthenticationRepository.instance.firebaseUser.value?.uid ==
//                   'OKhWgOI8wSN34M3pODpDDAK8ULW2') {
//                 await Future.delayed(const Duration(seconds: 5));
//                 await _controller.verifyMfaComplete(code);
//               } else {
//                 await _controller.verifyMfaComplete(code);
//               }
//               setState(() {
//                 _isLoadingVerify = !_isLoadingVerify;
//               });
//             } else if (_onChangeCode == null) {
//               _controller.incorrectInput();
//             }
//           },
//         ),
//         _isLoadingVerify == true
//             ? Column(
//                 children: [
//                   SizedBox(
//                     height: 20,
//                   ),
//                   const Text(
//                     "Verifying...",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: AppColors.mediumGrey,
//                       fontFamily: 'Raleway',
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               )
//             : SizedBox.shrink(),
//         const SizedBox(height: 60),
//         GestureDetector(
//           onTap: () async {
//             setState(() {
//               _isLoadingSendCode = !_isLoadingSendCode;
//             });

//             await _controller.resendMfaCode();
//             setState(() {
//               _isLoadingSendCode = !_isLoadingSendCode;
//             });
//           },
//           child: _isLoadingSendCode == true
//               ? CircularProgressIndicator.adaptive()
//               : Text(
//                   "Resend Code",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: AppColors.navy,
//                     fontFamily: 'Raleway',
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//         ),
//         const SizedBox(height: 80),
//         GestureDetector(
//           onTap: () {
//             PopupYesNo.showInfoDialog(
//               context,
//               mainText: 'Are you sure you want to log out?',
//               onYesPressed: () => _controller.logoutMfa(),
//             );
//           },
//           child: const Text(
//             "Logout",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: AppColors.green,
//               fontFamily: 'Raleway',
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

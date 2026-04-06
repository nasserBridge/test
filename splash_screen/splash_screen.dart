import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/image_strings.dart';
import 'package:bridgeapp/src/features/authentication/controllers/splash_screen_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/splash_screen/login_field.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  final _splashController = Get.put(SplashScreenController());
  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _splashController.startAnimation();
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: ListView(children: [
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center horizontally
              mainAxisSize: MainAxisSize.max, // Expand to fill vertical space
              children: [
                Obx(
                  () => AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      margin: EdgeInsets.only(
                          top: _splashController.animateLogo.value
                              ? screenHeight * Scale.x(.15)
                              : (_splashController.animateBridge.value
                                  ? 300
                                  : screenHeight * .15)),
                      child: SizedBox(
                          width: Scale.x(180),
                          child: Image(image: AssetImage(greenBridge)))),
                ),
                Obx(
                  () => AnimatedContainer(
                    width: Scale.x(10),
                    height: Scale.x(10),
                    duration: const Duration(milliseconds: 1000),
                    margin: EdgeInsets.only(
                      top: _splashController.animateBridge.value
                          ? Scale.x(5)
                          : Scale.x(150),
                    ),
                  ),
                ),
                Obx(
                  () => AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _splashController.animateText.value ? 1 : 0,
                    child: SizedBox(
                      width: Scale.x(180),
                      child: Image(
                        image: AssetImage(bridgeText),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _splashController.animateLogin.value ? 1 : 0,
                    child: const LoginField(),
                  ),
                ),
                SizedBox(
                  height: Scale.x(60),
                )
              ],
            ),
          ]),
        ));
  }
}

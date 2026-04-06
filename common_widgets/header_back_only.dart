import 'package:bridgeapp/src/features/authentication/screens/splash_screen/splash_screen.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeaderBackOnly extends StatelessWidget implements PreferredSizeWidget {
  const HeaderBackOnly({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () {
          Get.to(() => SplashScreen());
        },
        icon: const Icon(
          Icons.arrow_back_ios_new,
        ),
      ),
      title: Image.asset(
        'assets/images/greenBridge.png',
        height: Scale.x(45),
        fit: BoxFit.contain,
        //scale the image down.
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(Scale.x(kToolbarHeight));
}

import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/plaid_controller.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const HeaderBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(Scale.x(kToolbarHeight));

  @override
  Widget build(BuildContext context) {
    final PlaidController plaidController = Get.put(PlaidController());

    return PreferredSize(
      preferredSize: Size.fromHeight(Scale.x(65)),
      child: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                HapticFeedback.lightImpact();
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: const Text(
          'BRIDGE',
          style: TextStyle(
            color: AppColors.white,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            return IconButton(
              onPressed: plaidController.isProcessing.value
                  ? null
                  : () async {
                      HapticFeedback.lightImpact();
                      plaidController.plaidConnection();
                    },
              icon: const Icon(Icons.add, color: AppColors.white),
            );
          }),
        ],
      ),
    );
  }
}

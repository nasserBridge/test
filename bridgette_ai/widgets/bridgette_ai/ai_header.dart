import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/ai_controller.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AIHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const AIHeaderBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(Scale.x(kToolbarHeight));

  @override
  Widget build(BuildContext context) {
    final aiController = Get.put(AIController());

    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: AppBar(
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.manage_search,
                size: Scale.x(33),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: Image.asset(
          'assets/images/greenBridge.png',
          height: Scale.x(45),
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              FocusScope.of(context).unfocus(); // Dismiss the keyboard
              aiController.clearActiveConversation();
            },
            icon: Icon(
              Icons.edit_outlined,
              //size: Scale.x(24),
            ),
          )
        ],
      ),
    );
  }
}

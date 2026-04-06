import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/widgets/shared/icon_ink_response.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/controllers/appbar_onboarding_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/controllers/master_onboarding_controller.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OnboardingAppBar extends StatefulWidget implements PreferredSizeWidget {
  const OnboardingAppBar({super.key});

  static double _bottomPanelHeight() => Scale.x(130);

  @override
  Size get preferredSize =>
      Size.fromHeight(Scale.x(kToolbarHeight) + _bottomPanelHeight());

  @override
  State<OnboardingAppBar> createState() => _OnboardingAppBarState();
}

class _OnboardingAppBarState extends State<OnboardingAppBar> {
  final _controller = Get.put(AppbarOnboardingController());
  final _masterController = Get.put(MasterOnboardingController());
  Size get preferredSize => Size.fromHeight(
      Scale.x(kToolbarHeight) + OnboardingAppBar._bottomPanelHeight());

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,

        // ✅ Make the whole app bar white and clip its bottom with a radius
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors
            .transparent, // avoids Material 3 tint making white look grayish
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(Scale.x(30)),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark, // dark status bar icons
        automaticallyImplyLeading: false,
        leading: _backButton(),
        centerTitle: true,
        title: _logoImage(),
        actions: [_exitButton()],

        // ✅ Keep content in bottom; no extra BoxDecoration/rounded corners here
        bottom: _appBarBody());
  }

  Widget _backButton() {
    return Obx(() {
      return _masterController.currentPage.value == 0
          ? SizedBox.shrink()
          : IconButton(
              onPressed: () {
                _masterController.backOnePage();
              },
              icon: const Icon(Icons.arrow_back_ios_new),
              color: AppColors.navy,
            );
    });
  }

  Widget _logoImage() {
    return Image.asset(
      'assets/images/greenBridge.png',
      height: Scale.x(45),
      fit: BoxFit.contain,
    );
  }

  Widget _exitButton() {
    return Padding(
      padding: EdgeInsets.only(right: Scale.x(20.0)),
      child: IconInkResponse(
        icon: Icons.exit_to_app_outlined,
        onTap: () => Get.back(),
        size: 27,
      ),
    );
  }

  PreferredSize _appBarBody() {
    return PreferredSize(
      preferredSize: Size.fromHeight(OnboardingAppBar._bottomPanelHeight()),
      child: Padding(
        padding: EdgeInsets.only(
          top: Scale.x(30),
          left: Scale.x(60),
          right: Scale.x(0),
          bottom: Scale.x(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Align(
              alignment: Alignment.centerLeft,
              child: Obx(() {
                final title = _controller.appBarTitle.value;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500), // tweak to taste
                  // we handle the timing inside transitionBuilder, so keep these linear
                  switchInCurve: Curves.linear,
                  switchOutCurve: Curves.linear,
                  transitionBuilder: (child, animation) {
                    // Same interval for both directions:
                    // - Incoming (forward 0→1): visible only in 0.5..1.0 (fade in)
                    // - Outgoing (reverse 1→0): visible only in 1.0..0.5 (fade out)
                    final phased = CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
                    );
                    return FadeTransition(opacity: phased, child: child);
                  },
                  // Stack preserves left alignment and lets old/new overlap cleanly
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  ),
                  child: Text(
                    title,
                    key: ValueKey(title), // must change when text changes
                    style: TextStyle(
                      color: AppColors.navy,
                      fontFamily: 'Raleway',
                      fontSize: Scale.x(FontSizes.titleELCOME),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ),

            SizedBox(height: Scale.x(15)),

            // Subtitle
            Align(
              alignment: Alignment.centerLeft,
              child: Obx(() {
                final sub = _controller.appBarSubTitle.value;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.linear,
                  switchOutCurve: Curves.linear,
                  transitionBuilder: (child, animation) {
                    final phased = CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
                    );
                    return FadeTransition(opacity: phased, child: child);
                  },
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  ),
                  child: Text(
                    sub,
                    key: ValueKey(sub),
                    style: TextStyle(
                      color: AppColors.navy,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: Scale.x(16),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

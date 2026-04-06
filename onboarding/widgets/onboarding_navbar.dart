import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/controllers/navbar_onboarding_controller.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingNavbar extends StatefulWidget {
  const OnboardingNavbar({super.key});

  @override
  State<OnboardingNavbar> createState() => _OnboardingNavbarState();
}

class _OnboardingNavbarState extends State<OnboardingNavbar> {
  final _controller = Get.put(NavbarOnboardingController());

  @override
  Widget build(BuildContext context) {
    return _onboardingNavBar();
  }

  Container _onboardingNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Scale.x(30)),
          topRight: Radius.circular(Scale.x(30)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pageIndicatorWidget(),
          _cardList(),
        ],
      ),
    );
  }

  Padding _pageIndicatorWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, Scale.x(20), 0, Scale.x(30)),
      child: Center(
        child: SmoothPageIndicator(
          controller: _controller.pageChanger,
          count: _controller.factTextList.length,
          effect: ScrollingDotsEffect(
            activeDotColor: AppColors.green,
            dotColor: AppColors.blue,
            dotHeight: Scale.x(6),
            dotWidth: Scale.x(10),
            spacing: Scale.x(6),
          ),
        ),
      ),
    );
  }

  Widget _cardList() {
    final facts = _controller.factTextList;
    return SizedBox(
      height: Scale.x(120),
      child: PageView.builder(
        controller: _controller.pageChanger,
        onPageChanged: (index) {
          _controller.currentPage.value = index;
        },
        itemCount: facts.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index < 0 || index >= facts.length) {
            return const SizedBox.shrink();
          }
          return _didYouKnowCard(facts[index]);
        },
      ),
    );
  }

  Widget _didYouKnowCard(String factText) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Did You Know?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navy,
            fontFamily: 'Raleway',
            fontSize: Scale.x(16),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: Scale.x(20)),
        Text(
          factText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navy,
            fontFamily: 'Raleway',
            fontSize: Scale.x(14),
          ),
        ),
      ],
    );
  }
}

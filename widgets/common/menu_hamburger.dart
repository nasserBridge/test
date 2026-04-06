import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/common_widgets/popup_yes_no.dart';
import 'package:bridgeapp/src/features/authentication/screens/profile/feedbackpage.dart';
import 'package:bridgeapp/src/features/authentication/screens/profile/manage_accounts_page.dart';
import 'package:bridgeapp/src/features/authentication/screens/profile/privacy_settings.dart';
import 'package:bridgeapp/src/features/authentication/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridgeapp/src/features/authentication/controllers/profile_controller.dart';

class MenuHamburger extends StatelessWidget {
  final _controller = Get.put(ProfileController());
  MenuHamburger({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: _textFormat('View Profile'),
              onTap: () {
                Get.to(() => const ProfileScreen());
              },
            ),
            ListTile(
              title: _textFormat('Privacy Settings'),
              onTap: () {
                Get.to(() => const PrivacySettingsPage());
              },
            ),
            ListTile(
              title: _textFormat('Manage Accounts'),
              onTap: () {
                Get.to(() => ManageAccountsPage());
              },
            ),
            ListTile(
              title: _textFormat('Submit Feedback'),
              onTap: () {
                Get.to(() => const FeedbackPage());
              },
            ),
            ListTile(
              title: _textFormat('Logout'),
              onTap: () {
                PopupYesNo.showInfoDialog(
                  context,
                  mainText: 'Are you sure you want to logout?',
                  onYesPressed: () => _controller.logoutDelete(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _textFormat(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FontSizes.statements,
        color: AppColors.navy,
      ),
    );
  }
}

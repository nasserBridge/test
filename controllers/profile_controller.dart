import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/features/authentication/models/update_user_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/profile/mfa_update.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:bridgeapp/src/repository/authentication_repository/smarty_api.dart';
import 'package:bridgeapp/src/repository/user_repository/update_user_repository.dart';
import 'package:bridgeapp/src/repository/user_repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:bridgeapp/src/constants/url.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final _authRepo = Get.put(AuthenticationRepository());
  final _updateUserRepo = Get.put(UpdateUserRepository());
  final _userRepo = Get.put(UserRepository());

  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmNewPassword = TextEditingController();
  final smartyController = SmartyApi();

  void pushNameUpdate(UpdateNameUserModel user, String label) async {
    await _updateUserRepo.updateUser(user);
    _userRepo.boolName(label);
  }

  void pushAddressUpdate(UpdateAddressUserModel user, String label1) async {
    try {
      final rdi = await smartyController.checkAddress2(user);
      if (rdi == 'Residential') {
        await _updateUserRepo.updateUser(user);
        UserRepository.instance.boolName(label1);
      } else if (rdi == 'Commercial') {
        SnackbarService.show("You can't use a commercial address",
            isError: true);
      } else if (rdi == null) {
        SnackbarService.show('Please enter a valid address', isError: true);
      }
    } catch (error) {
      SnackbarService.show(error.toString(), isError: true);
    }
  }

  /// Attempts to change the password. If the account has MFA enrolled,
  /// Firebase throws during reauthentication — we catch the [kMfaRequiredSentinel],
  /// show the SMS overlay, and complete the update after the user submits their code.
  void pushPasswordUpdate(
      UpdatePasswordUserModel user, String label, BuildContext context) async {
    try {
      final email = _authRepo.firebaseUser.value?.email ?? '';
      await _authRepo.changePassword(
          email, oldPassword.text.trim(), user.password);
      await _updateUserRepo.updateUser(user);
      _userRepo.boolName(label);
    } catch (error) {
      if (error == kMfaRequiredSentinel) {
        OverlayHandler.showOverlay(
          // ✅ uses real context now
          context,
          message:
              'A verification code has been sent to your phone. Please enter it to confirm your password change.',
          onSubmit: (String smsCode) async {
            try {
              await _authRepo.updatePasswordAfterMfa(smsCode, user.password);
              await _updateUserRepo.updateUser(user);
              _userRepo.boolName(label);
            } catch (mfaError) {
              SnackbarService.show(mfaError.toString(), isError: true);
            }
          },
        );
      } else {
        SnackbarService.show(error.toString(), isError: true);
      }
    }
  }

  void pushDelete() async {
    try {
      String? token = await _authRepo.getIdToken();
      const String uri = apiUrl;
      String apiVersion = getAPIVersion();

      final headers = {
        'Authorization': 'Bearer $token',
        'Version': apiVersion,
      };

      final response = await http.post(
        Uri.parse('$uri/removeuser'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await _updateUserRepo.deleteFirestore();
        await _authRepo.deleteUser();
        await _authRepo.setInitialScreen(_authRepo.firebaseUser.value);
      } else if (response.statusCode == 426) {
        SnackbarService.show(
          'Please update your app to the latest version.',
          isError: true,
        );
      } else {
        SnackbarService.show('Try again later', isError: true);
      }
    } catch (error) {
      SnackbarService.show(error.toString(), isError: true);
    }
  }

  void logoutDelete() async {
    try {
      await _authRepo.logout();
    } catch (error) {
      SnackbarService.show(error.toString(), isError: true);
    }
  }
}

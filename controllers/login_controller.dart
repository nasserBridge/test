import 'dart:async';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();
  final _authrepo = Get.put(AuthenticationRepository());

  // Make mfaStatus observable
  var mfaStatus = false.obs;

  // TextField Controller to get data from TextFields.
  final email = TextEditingController();
  final password = TextEditingController();

  // Callable function to authenticate user for login
  Future<void> authUser(String email, String password) async {
    try {
      await _authrepo.loginWithEmailAndPassword(email, password);
      await _authrepo.setInitialScreen(_authrepo.firebaseUser.value);
    } catch (error) {
      if (error.toString() == 'Second factor authentication required') {
        SnackbarService.show('Code Sent');
      } else {
        SnackbarService.show(error.toString(), isError: true);
      }
    }
  }

  void changeMfaStatus() {
    mfaStatus.value = true; // Update observable variable
  }

  Future<void> verifyMfaComplete(String smsCode) async {
    try {
      await _authrepo.verifyMfaLoginCode(smsCode);
      await _authrepo.setInitialScreen(_authrepo.firebaseUser.value);
    } catch (error) {
      SnackbarService.show(error.toString(), isError: true);
    }
  }

  Future<void> resendMfaCode() async {
    try {
      await _authrepo.sendMfaLoginCode();
      SnackbarService.show('Code Sent');
    } catch (error) {
      SnackbarService.show(error.toString(), isError: true);
    }
  }

  void logoutMfa() async {
    try {
      await _authrepo.logout();
    } catch (error) {
      SnackbarService.show(error.toString(), isError: true);
    }
  }

  void incorrectInput() {
    SnackbarService.show('Code inputted incorrectly, try again.',
        isError: true);
  }
}

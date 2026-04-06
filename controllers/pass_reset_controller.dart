import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PasswordResetController extends GetxController {
  static PasswordResetController get instance => Get.find();
  final _authrepo = Get.put(AuthenticationRepository());
  // Create a StreamController to handle the stream of bank data.

  //TextField Controller to get data from TextFields.
  final email = TextEditingController();

  //A callable function that authenticates existing user for login
  void sendLink(String email) async {
    try {
      //attempt authenicating the user
      await _authrepo.forgotPassword(email);
      SnackbarService.show('Password reset link sent if account exists.');
    } catch (error) {
      SnackbarService.show(error.toString(), isError: true);
    }
  }
}

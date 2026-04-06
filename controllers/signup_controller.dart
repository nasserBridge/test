import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/features/authentication/models/user_model.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:bridgeapp/src/repository/authentication_repository/smarty_api.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/config/env.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  //TextField Controller to get data from TextFields.
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phoneNo = TextEditingController();
  final email = TextEditingController();
  final address1 = TextEditingController();
  final address2 = TextEditingController();
  final state = TextEditingController();
  final city = TextEditingController();
  final zipcode = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final smartyController = Get.put(SmartyApi());
  final _authcontroller = Get.put(AuthenticationRepository());

  Future<void> registerUser(UserModel user) async {
    try {
      if (Env.enableAddressValidation) {
        final rdi = await smartyController.checkAddress(user);
        if (rdi == 'Residential') {
          await AuthenticationRepository.instance
              .createUserWithEmailAndPassword(user, password.text.trim());
          await _authcontroller
              .setInitialScreen(_authcontroller.firebaseUser.value);
        } else if (rdi == 'Commercial') {
          SnackbarService.show("You can't use a commercial address",
              isError: true);
          return;
        } else if (rdi == null) {
          SnackbarService.show('Please enter a valid address', isError: true);
          return;
        }
      } else {
        // Skip address validation
        await AuthenticationRepository.instance
            .createUserWithEmailAndPassword(user, password.text.trim());
        await _authcontroller
            .setInitialScreen(_authcontroller.firebaseUser.value);
      }
    } catch (error) {
      SnackbarService.show(error.toString(), isError: true);
    }
  }
}

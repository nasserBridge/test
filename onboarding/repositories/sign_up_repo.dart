import 'package:bridgeapp/src/features/authentication/screens/onboarding/models/user_onboarding_model.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:get/get.dart';

class SignUpRepo extends GetxController {
  static SignUpRepo get instance => Get.find();

  final _auth = Get.put(AuthenticationRepository());

  Rx<UserOnboardingModel> user = UserOnboardingModel().obs;

  @override
  void onClose() {
    user = UserOnboardingModel().obs;
    super.onClose();
  }
}

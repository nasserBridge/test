import 'package:bridgeapp/src/features/authentication/screens/onboarding/controllers/master_onboarding_controller.dart';
import 'package:get/get.dart';

class AppbarOnboardingController extends GetxController {
  static AppbarOnboardingController get instance => Get.find();

  final _controller = Get.put(MasterOnboardingController());
  RxString appBarTitle = 'Begin Streamlining Your Finances!'.obs;
  RxString appBarSubTitle = 'Enter your email to get started.'.obs;
  late Worker _pageListener;

  @override
  void onInit() {
    super.onInit();
    // React whenever currentPage changes
    _pageListener = ever<int>(_controller.currentPage, (page) {
      changeAppBarText(page);
    });
  }

  @override
  void onClose() {
    appBarTitle = ''.obs;
    appBarSubTitle = ''.obs;
    _pageListener.dispose();
    super.onClose();
  }

  void changeAppBarText(int page) {
    switch (page) {
      case 0:
        appBarTitle.value = 'Begin Streamlining Your Finances!';
        appBarSubTitle.value = 'Enter your email to get started.';
      case 1:
        appBarTitle.value = 'Time To Create Your Account!';
        appBarSubTitle.value = 'Enter a secure password.';
      default:
        appBarTitle.value = 'Begin Streamlining Your Finances!';
        appBarSubTitle.value = 'Enter your email to get started.';
    }
  }
}

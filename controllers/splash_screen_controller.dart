import 'package:get/get.dart';



class SplashScreenController extends GetxController{
  static SplashScreenController get find => Get.find();
  
 
  RxBool animateText = false.obs;
  RxBool animateBridge = false.obs;
  RxBool animateLogo = false.obs;
  RxBool animateLogin = false.obs;

    Future startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 0));
    animateBridge.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    animateText.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    animateLogo.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    animateLogin.value = true;
  }
}
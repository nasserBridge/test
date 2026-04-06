import 'package:bridgeapp/src/features/authentication/models/consent_model.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  final _authrepo =
      Get.put(AuthenticationRepository()); // ✅ Prevent circular dependency

  // Observable Onboarding Level and Statuses
  var onboardingStep = 'Pending'.obs;
  var emailStatus = 'Pending'.obs;
  var mfaStatus = 'Pending'.obs;
  var disclosuresStatus = 'Pending'.obs;

  void checkprogress() async {
    if (await _authrepo.isemailVerified() == false) {
      onboardingStep.value = 'level1';
    } else {
      emailStatus.value = 'Complete';
      onboardingStep.value = 'level2';
      await mfaEnrollStatus();
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _authrepo.verifyEmail();
      SnackbarService.show('Verification email sent');
    } catch (e) {
      SnackbarService.show(e.toString(), isError: true);
    }
  }

  void manuallyCheckEmailVerificationStatus() async {
    try {
      bool verified = await _authrepo.isemailVerified();
      if (verified) {
        emailStatus.value = 'Complete';
        onboardingStep.value = 'level2';
        await sendPhoneVerification();
      } else {
        SnackbarService.show('Please verify your email', isError: true);
      }
    } catch (e) {
      SnackbarService.show('An error occurred: $e', isError: true);
    }
  }

  Future<void> sendPhoneVerification() async {
    try {
      await _authrepo.sendEnrollMfaCode();
      SnackbarService.show('Code sent');
      //mfaCodeSent.value = true; // ✅ Mark MFA as sent
    } catch (e) {
      SnackbarService.show(e.toString(), isError: true);
    }
  }

  Future<void> checkPhoneVerification(String smsCode) async {
    try {
      await _authrepo.checkEnrollMfaCode(smsCode);
      mfaStatus.value = 'Complete';
      onboardingStep.value = 'level3';
    } catch (e) {
      SnackbarService.show(e.toString(), isError: true);
    }
  }

  Future<void> mfaEnrollStatus() async {
    try {
      final multiFactor = await _authrepo.verifyMfa();
      if (multiFactor!.isEmpty) {
        await sendPhoneVerification();
      } else {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(_authrepo.firebaseUser.value?.uid)
            .update({'phoneVerified': true});
        mfaStatus.value = 'Complete';
        onboardingStep.value = 'level3';
      }
    } catch (e) {
      SnackbarService.show(e.toString(), isError: true);
    }
  }

  Future<void> logoutOnboarding() async {
    try {
      await _authrepo.logout();
    } catch (e) {
      SnackbarService.show('An error occurred: $e', isError: true);
    }
  }

  Future<void> completeOnboarding(
      String userId,
      bool acceptAllChecked,
      bool acceptAllDataUsage,
      bool marketingCommunications,
      bool dataUse,
      bool anonymizedDataSharing) async {
    try {
      await saveConsentPreferences(
        userId,
        acceptAllChecked,
        acceptAllDataUsage,
        marketingCommunications,
        dataUse,
        anonymizedDataSharing,
      );

      if (acceptAllChecked) {
        _authrepo.setInitialScreen(_authrepo.firebaseUser.value);
      } else {
        SnackbarService.show('Please accept all disclosures to proceed.',
            isError: true);
      }
    } catch (e) {
      SnackbarService.show('An error occurred: $e', isError: true);
    }
  }

  void incorrectInput() {
    SnackbarService.show(
      'Code inputted incorrectly, try again.',
      isError: true,
    );
  }
}

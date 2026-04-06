import 'package:bridgeapp/src/features/authentication/screens/navigation/app_navigation.dart';
import 'package:bridgeapp/src/features/authentication/controllers/login_controller.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/onboarding.dart';
import 'package:bridgeapp/src/features/authentication/screens/splash_screen/splash_screen.dart';
import 'package:bridgeapp/src/repository/authentication_repository/exceptions/firebase_exception_handling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridgeapp/src/repository/user_repository/user_repository.dart';
import 'package:bridgeapp/src/features/authentication/models/user_model.dart';

/// Sentinel thrown by [changePassword] when MFA resolution is required.
/// The controller catches this and shows the MFA overlay.
const String kMfaRequiredSentinel = 'mfa-required';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _userRepo = Get.put(UserRepository());
  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;
  late bool consentCheck = false;
  late String _verificationId;
  late MultiFactorResolver _resolver;

  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    setInitialScreen(firebaseUser.value);
  }

  Future<void> setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAll(() => SplashScreen());
    } else {
      await checkAcceptAllChecked(user.uid);
      if (consentCheck) {
        Get.offAll(() => const AppNavigation());
      } else {
        Get.offAll(() => const OnBoardingScreen());
      }
    }
  }

  Future<void> createUserWithEmailAndPassword(
      UserModel user, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: user.email, password: password);

      final uid = result.user?.uid;

      if (uid != null) {
        await result.user?.sendEmailVerification();
        await _userRepo.createUser(user, uid);
      }
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } on Exception catch (e) {
      debugPrint(e.toString());
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> reauthenticateUser(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthMultiFactorException catch (e) {
      _resolver = e.resolver;
      LoginController.instance.changeMfaStatus();
      await sendMfaLoginCode();
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (e) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> sendMfaLoginCode() async {
    try {
      final firstHint = _resolver.hints.first;
      if (firstHint is! PhoneMultiFactorInfo) return;
      await _auth.verifyPhoneNumber(
        multiFactorSession: _resolver.session,
        multiFactorInfo: firstHint,
        verificationCompleted: (_) {},
        verificationFailed: (error) => debugPrint(error.toString()),
        codeSent: (String verificationId, int? resendToken) async {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (e) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> verifyMfaLoginCode(String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      await _resolver
          .resolveSignIn(PhoneMultiFactorGenerator.getAssertion(credential));
    } on FirebaseAuthMultiFactorException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      setInitialScreen(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> deleteUser() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  /// Attempts reauthentication then updates the password.
  ///
  /// If the account has MFA enrolled, reauthentication throws
  /// [FirebaseAuthMultiFactorException]. In that case this method stores the
  /// resolver, sends the SMS code, and throws [kMfaRequiredSentinel] so the
  /// caller can show the MFA overlay and later call [updatePasswordAfterMfa].
  Future<void> changePassword(
    String email,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
      await _auth.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthMultiFactorException catch (e) {
      // ✅ Store resolver and send SMS — then signal the controller
      _resolver = e.resolver;
      await sendMfaLoginCode();
      throw kMfaRequiredSentinel;
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (e) {
      if (e == kMfaRequiredSentinel) rethrow; // don't swallow our sentinel
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  /// Called after the user has submitted their MFA SMS code.
  /// Resolves the MFA challenge then updates the password.
  Future<void> updatePasswordAfterMfa(
      String smsCode, String newPassword) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      await _resolver
          .resolveSignIn(PhoneMultiFactorGenerator.getAssertion(credential));
      await _auth.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthMultiFactorException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<String?> getIdToken() async {
    final idToken = _auth.currentUser?.getIdToken();
    return idToken;
  }

  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> verifyEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<bool> isemailVerified() async {
    try {
      await reloadUser();

      if (_auth.currentUser?.emailVerified == true) {
        final uid = _auth.currentUser!.uid;
        final doc =
            await FirebaseFirestore.instance.collection('Users').doc(uid).get();
        final data = doc.data();

        if (data?['emailVerifiedAt'] == null) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(uid)
              .update({'emailVerifiedAt': FieldValue.serverTimestamp()});
        }
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } on FirebaseException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> sendEnrollMfaCode() async {
    try {
      final session = await _auth.currentUser?.multiFactor.getSession();
      final String phoneNo = await retrievePhoneNumber(firebaseUser.value?.uid);
      await _auth.verifyPhoneNumber(
        multiFactorSession: session,
        phoneNumber: phoneNo,
        verificationCompleted: (_) {},
        verificationFailed: (_) {},
        codeSent: (String verificationId, int? resendToken) async {
          _verificationId = verificationId;
          // if (Platform.isIOS) {
          //   Get.offAll(() => OnBoardingScreen());
          // }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> checkEnrollMfaCode(String smsCode) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.currentUser?.multiFactor.enroll(
          PhoneMultiFactorGenerator.getAssertion(credential),
          displayName: 'phone');
    } on FirebaseAuthMultiFactorException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } on Exception catch (e) {
      debugPrint(e.toString());
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<List<MultiFactorInfo>?> verifyMfa() async {
    try {
      return await firebaseUser.value?.multiFactor.getEnrolledFactors();
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> unenrollMfa() async {
    try {
      final factor = await verifyMfa();
      await _auth.currentUser?.multiFactor.unenroll(factorUid: factor?[0].uid);
    } on FirebaseAuthMultiFactorException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      final ex = ExceptionHandling.code(e.code).message;
      throw ex;
    } catch (_) {
      const ex = ExceptionHandling();
      throw ex;
    }
  }

  Future<void> checkAcceptAllChecked(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('userConsents')
              .doc(uid)
              .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('acceptAllChecked')) {
          final acceptAllChecked = data['acceptAllChecked'];
          consentCheck = acceptAllChecked is bool ? acceptAllChecked : false;
        } else {
          consentCheck = false;
        }
      } else {
        consentCheck = false;
      }
    } catch (e) {
      debugPrint(e.toString());
      SnackbarService.show(e.toString(), isError: true);
    }
  }

  Future<String> retrievePhoneNumber(String? userId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        final phoneNumber = userSnapshot.get('Phone');
        final strippedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
        return '+$strippedPhoneNumber';
      } else {
        throw Exception('User document not found in Firestore');
      }
    } catch (error) {
      throw Exception('Failed to retrieve phone number from Firestore: $error');
    }
  }
}

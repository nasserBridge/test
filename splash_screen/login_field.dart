import 'dart:async';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/controllers/login_controller.dart';
import 'package:bridgeapp/src/common_widgets/update_textformfield.dart';
import 'package:bridgeapp/src/features/authentication/screens/splash_screen/password_reset_screen.dart';
import 'package:bridgeapp/src/features/authentication/screens/signup/signup_screen.dart';
import 'package:bridgeapp/src/features/authentication/screens/splash_screen/mfa_login.dart';
import 'package:bridgeapp/src/repository/authentication_repository/validators.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridgeapp/src/features/authentication/models/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CredentialStorage {
  static Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    await prefs.setString('saved_password', password);
    await prefs.setBool('save_login', true);
  }

  static Future<Map<String, String?>> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('saved_email'),
      'password': prefs.getString('saved_password'),
    };
  }

  static Future<bool> loadSaveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('save_login') ?? false;
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
    await prefs.setBool('save_login', false);
  }
}

class LoginField extends StatefulWidget {
  const LoginField({super.key});

  @override
  LoginFieldState createState() => LoginFieldState();
}

class LoginFieldState extends State<LoginField> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final controller = Get.put(LoginController());
  bool mfaLogin = false;
  late StreamSubscription<bool> streamMfaLogin;
  bool isLoading = false;
  bool saveLogin = false; // "Remember me" state
  bool hasSavedPassword = false; // Track if password is saved

  @override
  void initState() {
    super.initState();
    // print(mfaLogin);
    // print('restarted');
    // streamMfaLogin = controller.mfaLoginStream.listen((data) {
    //   print(data);
    //   setState(() => mfaLogin = data);
    // });
    loadSavedCredentials(); // Load credentials and checkbox state
  }

  @override
  void dispose() {
    //streamMfaLogin.cancel();
    super.dispose();
  }

  Future<void> loadSavedCredentials() async {
    final credentials = await CredentialStorage.loadCredentials();
    final savedLoginState = await CredentialStorage.loadSaveLoginState();

    setState(() {
      saveLogin = savedLoginState;
      hasSavedPassword = credentials['password'] != null;

      if (saveLogin && hasSavedPassword) {
        controller.email.text = credentials['email'] ?? '';
        controller.password.text = credentials['password'] ?? '';
      }
    });
  }

  Future<void> handleLogin() async {
    if (formKey.currentState!.validate()) {
      final user = AuthModel(
        email: controller.email.text.trim(),
        password: controller.password.text.trim(),
      );

      setState(() {
        isLoading = true;
      });

      await LoginController.instance.authUser(user.email, user.password);

      if (saveLogin) {
        await CredentialStorage.saveCredentials(user.email, user.password);
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          color: AppColors.white,
          margin: EdgeInsets.only(
              top: Scale.x(40), left: Scale.x(55), right: Scale.x(55)),
          child: Obx(() => controller.mfaStatus.value
              ? const MfaLogin()
              : Form(
                  key: formKey,
                  child: Column(
                    children: [
                      hasSavedPassword == false
                          ? SizedBox.fromSize()
                          : SizedBox(height: Scale.x(40)),
                      UpdateTextFormField(
                        controller: controller.email,
                        label: 'E-Mail',
                        validator: FormValidators.validateLoginEmail,
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      SizedBox(height: Scale.x(30)),
                      if (!hasSavedPassword)
                        UpdateTextFormField(
                          controller: controller.password,
                          label: 'Password',
                          validator: FormValidators.validateLoginPassword,
                          prefixIcon: Icons.fingerprint,
                        ),
                      SizedBox(height: Scale.x(10)),
                      hasSavedPassword == false
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      side: BorderSide(color: AppColors.navy),
                                      activeColor: AppColors.navy,
                                      checkColor: AppColors.white,
                                      value: saveLogin,
                                      onChanged: (bool? value) async {
                                        setState(() {
                                          saveLogin = value ?? false;
                                        });

                                        if (!saveLogin) {
                                          await CredentialStorage
                                              .clearCredentials();
                                        }
                                      },
                                    ),
                                    Text(
                                      'Remember Me',
                                      style: TextStyle(
                                        color: AppColors.navy,
                                        fontFamily: 'Raleway',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Scale.x(45)),
                              ],
                            )
                          : SizedBox(height: Scale.x(10)),
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(Scale.x(50), 0, Scale.x(50), 0),
                        child: Column(
                          children: [
                            hasSavedPassword == true
                                ? Column(
                                    children: [
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          fixedSize: WidgetStateProperty.all(
                                              Size(double.maxFinite,
                                                  Scale.x(15))),
                                          backgroundColor:
                                              WidgetStateColor.resolveWith(
                                                  (states) => AppColors.green),
                                          foregroundColor:
                                              WidgetStateColor.resolveWith(
                                                  (states) => AppColors.white),
                                          overlayColor:
                                              WidgetStateColor.resolveWith(
                                                  (states) => AppColors.navy),
                                        ),
                                        onPressed: handleLogin,
                                        child: isLoading
                                            ? const CircularProgressIndicator
                                                .adaptive()
                                            : Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontFamily: 'Raleway',
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: Scale.x(1.5),
                                                ),
                                              ),
                                      ),
                                      SizedBox(height: Scale.x(100)),
                                      GestureDetector(
                                        onTap: () async {
                                          await CredentialStorage
                                              .clearCredentials();
                                          setState(() {
                                            saveLogin = false;
                                            hasSavedPassword = false;
                                            controller.email.clear();
                                            controller.password.clear();
                                          });
                                        },
                                        child: Text(
                                          'Switch Account',
                                          style: TextStyle(
                                            color: AppColors.navy,
                                            fontFamily: 'Raleway',
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: Scale.x(1.0),
                                            //decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      OutlinedButton(
                                        style: ButtonStyle(
                                          fixedSize: WidgetStateProperty.all(
                                              Size(double.maxFinite,
                                                  Scale.x(15))),
                                          side:
                                              WidgetStateBorderSide.resolveWith(
                                                  (states) => const BorderSide(
                                                      color: AppColors.green)),
                                          foregroundColor:
                                              WidgetStateColor.resolveWith(
                                                  (states) => AppColors.green),
                                          overlayColor:
                                              WidgetStateColor.resolveWith(
                                                  (states) => AppColors.navy),
                                        ),
                                        onPressed: handleLogin,
                                        child: isLoading
                                            ? const CircularProgressIndicator
                                                .adaptive()
                                            : Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontFamily: 'Raleway',
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: Scale.x(1.5),
                                                ),
                                              ),
                                      ),
                                      SizedBox(height: Scale.x(5)),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          fixedSize: WidgetStateProperty.all(
                                              Size(double.maxFinite,
                                                  Scale.x(15))),
                                          backgroundColor:
                                              WidgetStateColor.resolveWith(
                                                  (states) => AppColors.green),
                                          foregroundColor:
                                              WidgetStateColor.resolveWith(
                                                  (states) => AppColors.white),
                                          overlayColor:
                                              WidgetStateColor.resolveWith(
                                                  (states) => AppColors.navy),
                                        ),
                                        onPressed: () {
                                          Get.to(() => const SignUpScreen()
                                              //() => const OnboardingScreenNew(),
                                              );
                                        },
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontFamily: 'Raleway',
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: Scale.x(1.5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(height: Scale.x(40)),
                      hasSavedPassword == true
                          ? SizedBox.shrink()
                          : Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => PasswordResetScreen());
                                  },
                                  child: Text(
                                    'Forgot Password',
                                    style: TextStyle(
                                      color: AppColors.navy.withValues(alpha: .6),
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: Scale.x(.25),
                                    ),
                                  ),
                                ),
                                SizedBox(height: Scale.x(50)),
                                Text(
                                  "By creating an account, you agree to our Privacy Policy, Terms of Use, EULA, and Cookie Policy.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.navy.withValues(alpha: .6),
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: Scale.x(.25),
                                    fontSize: Scale.x(11),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                )),
        ),
      ],
    );
  }
}

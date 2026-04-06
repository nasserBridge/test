import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/states.dart';
import 'package:bridgeapp/src/features/authentication/controllers/signup_controller.dart';
import 'package:bridgeapp/src/common_widgets/custom_dropdownformfield.dart';
import 'package:bridgeapp/src/common_widgets/header_back_only.dart';
import 'package:bridgeapp/src/common_widgets/custom_textformfield.dart';
import 'package:bridgeapp/src/features/authentication/models/user_model.dart';
import 'package:bridgeapp/src/repository/authentication_repository/phone_formatter.dart';
import 'package:bridgeapp/src/repository/authentication_repository/validators.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _controller = Get.put(SignUpController());
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final FormValidators _formValidators = FormValidators();
  bool _isloading = false;
  bool _saveLoginOnce = false; // One-time "Remember me" state

  Future<void> saveCredentialsOnce(String email) async {
    final prefs = await SharedPreferences.getInstance();
    // Only save credentials if they have not been saved previously
    if (!(prefs.containsKey('saved_email'))) {
      await prefs.setString('saved_email', email);

      await prefs.setBool('save_login', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const HeaderBackOnly(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
              top: Scale.x(30), left: Scale.x(50), right: Scale.x(50)),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'W',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w600,
                        fontSize: Scale.x(25),
                      ),
                    ),
                    Text(
                      'ELCOME!',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w600,
                        fontSize: Scale.x(21),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Scale.x(10)),
                const Text(
                    'Create your profile and streamline your finances today!'),
                SizedBox(height: Scale.x(30)),
                CustomTextFormField(
                  controller: _controller.firstName,
                  label: 'Legal First Name',
                  validator: FormValidators.validateFirstName,
                  prefixIcon: Icons.person_outline_rounded,
                ),
                SizedBox(height: Scale.x(20)),
                CustomTextFormField(
                  controller: _controller.lastName,
                  label: 'Legal Last Name',
                  validator: FormValidators.validateLastName,
                  prefixIcon: Icons.person_outline_rounded,
                ),
                SizedBox(height: Scale.x(20)),
                CustomTextFormField(
                  controller: _controller.phoneNo,
                  label: 'Phone Number',
                  validator: FormValidators.validatePhoneNumber,
                  prefixIcon: Icons.call_outlined,
                  inputFormatter: PhoneNumberFormatter(),
                ),
                SizedBox(height: Scale.x(10)),
                CustomTextFormField(
                  controller: _controller.email,
                  label: 'E-Mail',
                  validator: FormValidators.validateSignUpEmail,
                  prefixIcon: Icons.mail_outline_rounded,
                ),
                SizedBox(height: Scale.x(20)),
                CustomTextFormField(
                  controller: _controller.address1,
                  label: 'Residential Address',
                  validator: _formValidators.validateAddressLine1,
                  prefixIcon: Icons.home_outlined,
                ),
                SizedBox(height: Scale.x(20)),
                CustomTextFormField(
                  controller: _controller.address2,
                  label: 'Ste, Apt, Other...',
                  validator: FormValidators.validateAddressLine2,
                  prefixIcon: Icons.home_outlined,
                ),
                SizedBox(height: Scale.x(20)),
                CustomTextFormField(
                  controller: _controller.city,
                  label: 'City',
                  validator: FormValidators.validateCity,
                  prefixIcon: Icons.location_city_outlined,
                ),
                SizedBox(height: Scale.x(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: CustomDropdownFormField(
                        label: 'State',
                        prefixIcon: Icons.location_on,
                        selectedValue: _controller.state.text.isNotEmpty
                            ? _controller.state.text
                            : null,
                        items: States.all,
                        onChanged: (value) {
                          setState(() {
                            _controller.state.text = value ?? '';
                          });
                        },
                        validator: FormValidators.validateState,
                      ),
                    ),
                    SizedBox(width: Scale.x(16)),
                    Flexible(
                      fit: FlexFit.tight,
                      child: CustomTextFormField(
                        controller: _controller.zipcode,
                        label: 'Zip Code',
                        validator: FormValidators.validateZipcode,
                        prefixIcon: null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Scale.x(20)),
                CustomTextFormField(
                  controller: _controller.password,
                  label: 'Password',
                  validator: FormValidators.validateSignUpPassword,
                  prefixIcon: Icons.fingerprint,
                ),
                SizedBox(height: Scale.x(20)),
                CustomTextFormField(
                  controller: _controller.confirmPassword,
                  label: 'Confirm Password',
                  validator: (value) {
                    return FormValidators.validateConfirmPassword(
                        _controller.password.text.trim(), value);
                  },
                  prefixIcon: Icons.fingerprint,
                ),
                SizedBox(height: Scale.x(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      side: BorderSide(color: AppColors.navy),
                      activeColor: AppColors.navy,
                      checkColor: AppColors.white,
                      value: _saveLoginOnce,
                      onChanged: (bool? value) {
                        setState(() {
                          _saveLoginOnce = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Remember Login',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w600,
                        letterSpacing: Scale.x(1.0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Scale.x(20)),
                Padding(
                  padding: EdgeInsets.fromLTRB(Scale.x(40), 0, Scale.x(40), 50),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(
                          Size(double.maxFinite, Scale.x(15))),
                      backgroundColor: WidgetStateColor.resolveWith(
                          (states) => AppColors.green),
                      foregroundColor: WidgetStateColor.resolveWith(
                          (states) => AppColors.white),
                      overlayColor: WidgetStateColor.resolveWith(
                          (states) => AppColors.navy),
                    ),
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                        final user = UserModel(
                          firstName: _controller.firstName.text.trim(),
                          lastName: _controller.lastName.text.trim(),
                          address1: _controller.address1.text.trim(),
                          address2: _controller.address2.text.trim(),
                          city: _controller.city.text.trim(),
                          state: _controller.state.text.trim(),
                          zipcode: _controller.zipcode.text.trim(),
                          phoneNo: _controller.phoneNo.text.trim(),
                          email: _controller.email.text.trim(),
                        );

                        setState(() => _isloading = true);
                        await SignUpController.instance.registerUser(user);

                        // Save credentials only once if checkbox is selected
                        if (_saveLoginOnce) {
                          await saveCredentialsOnce(user.email);
                        }

                        setState(() => _isloading = false);
                      }
                    },
                    child: _isloading
                        ? const CircularProgressIndicator.adaptive()
                        : Text('Create Account',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w600,
                              letterSpacing: Scale.x(1.5),
                            )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

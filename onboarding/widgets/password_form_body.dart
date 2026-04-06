import 'package:bridgeapp/src/features/authentication/screens/onboarding/controllers/password_onboarding_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/onboarding_textformfield.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_button.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:bridgeapp/src/repository/authentication_repository/validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/utils/scale.dart';

class PasswordFormBody extends StatelessWidget {
  PasswordFormBody({super.key});

  final _controller = Get.put(PasswordOnboardingController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: Scale.x(160)),
        _enterPasswordTextEditor(),
        _createAccountButton(),
      ],
    );
  }

  Widget _enterPasswordTextEditor() {
    return WhiteContainer(
      child: Padding(
        padding: EdgeInsets.only(
            top: Scale.x(10),
            bottom: Scale.x(8),
            left: Scale.x(10),
            right: Scale.x(10)),
        child: Form(
          key: _controller.formkey,
          child: Column(
            children: [
              OnboardingTextFormField(
                controller: _controller.passwordTextEditor,
                label: 'Password',
                validator: FormValidators.validateSignUpPassword,
                prefixIcon: Icons.fingerprint,
              ),
              Divider(
                color: AppColors.navy,
                thickness: Scale.x(.25),
                // indent: Scale.x(0),
                // endIndent: Scale.x(35),
              ),
              OnboardingTextFormField(
                controller: _controller.confirmPasswordTextEditor,
                label: 'Confirm Password',
                validator: (value) {
                  return FormValidators.validateConfirmPassword(
                      _controller.passwordTextEditor.text.trim(), value);
                },
                prefixIcon: Icons.fingerprint,
              ),
              _rememberLoginCheckBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rememberLoginCheckBox() {
    return Padding(
      padding: EdgeInsets.only(
          top: Scale.x(5), bottom: Scale.x(5), right: Scale.x(9)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'Remember Login',
            style: TextStyle(
              color: AppColors.navy,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(width: Scale.x(10)),
          Obx(
            () => Checkbox(
              side: const BorderSide(color: AppColors.navy),
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: AppColors.navy,
              checkColor: AppColors.white,
              value: _controller.saveLogin.value,
              onChanged: (bool? value) {
                _controller.saveLogin.value = !_controller.saveLogin.value;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _createAccountButton() {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
          horizontal: Scale.x(30), vertical: Scale.x(40)),
      child: Row(
        children: [
          const Spacer(),
          WhiteButton(
            text: 'Create Account',
            textColor: AppColors.navy,
            onPressed: () {
              _controller.submitEmail();
            },
          ),
        ],
      ),
    );
  }
}

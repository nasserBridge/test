import 'package:bridgeapp/src/features/authentication/screens/onboarding/controllers/email_onboarding_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/onboarding_textformfield.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_button.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:bridgeapp/src/repository/authentication_repository/validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:sign_button/sign_button.dart';

class EmailFormBody extends StatefulWidget {
  const EmailFormBody({super.key});

  @override
  State<EmailFormBody> createState() => _EmailFormBodyState();
}

class _EmailFormBodyState extends State<EmailFormBody> {
  final _controller = Get.put(EmailOnboardingController());

  @override
  void dispose() {
    super.dispose();
    //_controller.manuallyDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: Scale.x(150)),
        _enterEmailTextEditor(),
        _emailGetStartedButton(),
        Divider(
          color: AppColors.navy,
          thickness: Scale.x(.25),
          indent: Scale.x(35),
          endIndent: Scale.x(35),
        ),
        _googleSignInButton(),
      ],
    );
  }

  Widget _enterEmailTextEditor() {
    return WhiteContainer(
      child: Padding(
        padding: EdgeInsets.only(
            top: Scale.x(5),
            bottom: Scale.x(5),
            left: Scale.x(10),
            right: Scale.x(10)),
        child: Form(
          key: _controller.formkey,
          child: OnboardingTextFormField(
            controller: _controller.emailTextEditor,
            label: 'E-Mail',
            validator: FormValidators.validateSignUpEmail,
            prefixIcon: Icons.mail_outline,
          ),
        ),
      ),
    );
  }

  Widget _emailGetStartedButton() {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
          horizontal: Scale.x(30), vertical: Scale.x(40)),
      child: Row(
        children: [
          const Spacer(),
          WhiteButton(
            text: 'Get Started',
            textColor: AppColors.navy,
            onPressed: () {
              _controller.submitEmail();
            },
          ),
        ],
      ),
    );
  }

  Widget _googleSignInButton() {
    return Padding(
      padding: EdgeInsets.only(top: Scale.x(40)),
      child: SignInButton(
          buttonType: ButtonType.google,
          buttonSize: ButtonSize.small,
          onPressed: () {}),
    );
  }
}

import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/controllers/pass_reset_controller.dart';
import 'package:bridgeapp/src/common_widgets/header_back_only.dart';
import 'package:bridgeapp/src/common_widgets/update_textformfield.dart';
import 'package:bridgeapp/src/repository/authentication_repository/validators.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordResetScreen extends StatelessWidget {
  final _controller = Get.put(PasswordResetController());
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: const HeaderBackOnly(),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(
                top: Scale.x(30), left: Scale.x(50), right: Scale.x(50)),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'P',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w600,
                        fontSize: Scale.x(22),
                      ),
                    ),
                    Text(
                      'assword ',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w600,
                        fontSize: Scale.x(18),
                      ),
                    ),
                    Text(
                      'R',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w600,
                        fontSize: Scale.x(22),
                      ),
                    ),
                    Text(
                      'eset',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w600,
                        fontSize: Scale.x(18),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Scale.x(30),
                ),
                SizedBox(
                  height: Scale.x(30),
                ),
                const Text(
                    'Enter your e-mail to receive a passwaord reset link.'),
                SizedBox(height: Scale.x(30)),
                Padding(
                  padding: EdgeInsets.fromLTRB(Scale.x(10), 0, 10, 0),
                  child: Form(
                    key: _formkey,
                    child: UpdateTextFormField(
                      controller: _controller.email,
                      label: 'E-Mail',
                      validator: FormValidators.validateForgotPassword,
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(Scale.x(35), 0, Scale.x(35), 0),
                  child: OutlinedButton(
                      style: ButtonStyle(
                        fixedSize: WidgetStateProperty.all(
                            Size(double.maxFinite, Scale.x(15))),
                        side: WidgetStateBorderSide.resolveWith((states) =>
                            const BorderSide(color: AppColors.green)),
                        foregroundColor: WidgetStateColor.resolveWith(
                            (states) => AppColors.green),
                        overlayColor: WidgetStateColor.resolveWith(
                            (states) => AppColors.navy),
                      ),
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          _controller.sendLink(_controller.email.text.trim());
                        }
                      },
                      child: Text('Send Verification Code',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                            letterSpacing: Scale.x(1.5),
                          ))),
                ),
                SizedBox(
                  height: Scale.x(20),
                ),
              ],
            ),
          ),
        ));
  }
}

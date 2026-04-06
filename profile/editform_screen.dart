import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/controllers/profile_controller.dart';
import 'package:bridgeapp/src/common_widgets/update_textformfield.dart';
import 'package:bridgeapp/src/features/authentication/models/update_user_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/profile/mfa_update.dart';
import 'package:bridgeapp/src/repository/authentication_repository/phone_formatter.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';

class EditForm extends StatelessWidget {
  final TextEditingController controller1;
  final String label1;
  final String? Function(String?)? validator1;
  final IconData prefixIcon1;
  final TextEditingController controller2;
  final String label2;
  final String? Function(String?)? validator2;
  final IconData prefixIcon2;
  final TextEditingController? controller3;
  final String? label3;
  final String? Function(String?)? validator3;
  final IconData? prefixIcon3;
  final TextEditingController? controller4;
  final String? label4;
  final String? Function(String?)? validator4;
  final IconData? prefixIcon4;
  final TextEditingController? controller5;
  final String? label5;
  final String? Function(String?)? validator5;
  final IconData? prefixIcon5;
  final _controller = Get.put(ProfileController());

  EditForm({
    super.key,
    required this.controller1,
    required this.label1,
    required this.validator1,
    required this.prefixIcon1,
    required this.controller2,
    required this.label2,
    required this.validator2,
    required this.prefixIcon2,
    this.controller3,
    this.label3,
    this.validator3,
    this.prefixIcon3,
    this.controller4,
    this.label4,
    this.validator4,
    this.prefixIcon4,
    this.controller5,
    this.label5,
    this.validator5,
    this.prefixIcon5,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formkey = GlobalKey<FormState>();
    return Form(
        key: formkey,
        child: Column(
          children: [
            UpdateTextFormField(
              controller: controller1,
              label: label1,
              validator: validator1,
              prefixIcon: prefixIcon1,
            ),
            SizedBox(height: Scale.x(20)),
            UpdateTextFormField(
              controller: controller2,
              label: label2,
              validator: validator2,
              prefixIcon: prefixIcon2,
              inputFormatter:
                  label2 == 'Phone Number' ? PhoneNumberFormatter() : null,
            ),
            label1 == 'Old Password'
                ? Column(
                    children: [
                      SizedBox(height: Scale.x(20)),
                      UpdateTextFormField(
                          controller: controller3,
                          label: label3,
                          validator: validator3,
                          prefixIcon: prefixIcon3),
                      SizedBox(height: Scale.x(40)),
                    ],
                  )
                : label1 == 'Physical Address'
                    ? Column(
                        children: [
                          SizedBox(height: Scale.x(20)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: Scale.x(170),
                                child: UpdateTextFormField(
                                    controller: controller3,
                                    label: label3,
                                    validator: validator3,
                                    prefixIcon: prefixIcon3),
                              ),
                              SizedBox(width: Scale.x(20)),
                              SizedBox(
                                width: Scale.x(35),
                                child: UpdateTextFormField(
                                    controller: controller4,
                                    label: label4,
                                    validator: validator4,
                                    prefixIcon: prefixIcon4),
                              ),
                              SizedBox(width: Scale.x(20)),
                              SizedBox(
                                width: Scale.x(60),
                                child: UpdateTextFormField(
                                    controller: controller5,
                                    label: label5,
                                    validator: validator5,
                                    prefixIcon: prefixIcon5),
                              ),
                            ],
                          ),
                          SizedBox(height: Scale.x(40)),
                        ],
                      )
                    : SizedBox(height: Scale.x(40)),
            OutlinedButton(
                style: ButtonStyle(
                  fixedSize:
                      WidgetStateProperty.all(Size(Scale.x(180), Scale.x(15))),
                  side: WidgetStateBorderSide.resolveWith(
                      (states) => const BorderSide(color: AppColors.green)),
                  foregroundColor:
                      WidgetStateColor.resolveWith((states) => AppColors.green),
                  overlayColor:
                      WidgetStateColor.resolveWith((states) => AppColors.navy),
                ),
                onPressed: () {
                  if (label1 == 'First Name') {
                    if (formkey.currentState!.validate()) {
                      final user = UpdateNameUserModel(
                        firstName: controller1.text.trim(),
                        lastName: controller2.text.trim(),
                      );
                      _controller.pushNameUpdate(user, label1);
                    }
                  } else if (label1 == 'E-Mail') {
                    if (formkey.currentState!.validate()) {
                      // ✅ onSubmit is required — placeholder until email update
                      // flow is implemented in pushContactUpdate
                      OverlayHandler.showOverlay(
                        context,
                        message:
                            'A verification code has been sent to your phone to confirm this change.',
                        onSubmit: (String code) async {
                          // TODO: implement _controller.pushContactUpdate(...)
                        },
                      );
                    }
                  } else if (label1 == 'Physical Address') {
                    if (formkey.currentState!.validate()) {
                      final user = UpdateAddressUserModel(
                        address1: controller1.text.trim(),
                        address2: controller2.text.trim(),
                        city: controller3!.text.trim(),
                        state: controller4!.text.trim(),
                        zipcode: controller5!.text.trim(),
                      );
                      _controller.pushAddressUpdate(user, label1);
                    }
                  } else if (label1 == 'Old Password') {
                    if (formkey.currentState!.validate()) {
                      final user = UpdatePasswordUserModel(
                        password: controller2.text.trim(),
                      );
                      _controller.pushPasswordUpdate(
                          user, label1, context); // ✅ pass context
                    }
                  }
                },
                child: Text('Save Changes',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                      letterSpacing: Scale.x(1.5),
                    ))),
            SizedBox(height: Scale.x(40)),
          ],
        ));
  }
}

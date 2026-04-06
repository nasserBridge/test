import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/widgets/shared/icon_ink_response.dart';
import 'package:bridgeapp/src/repository/authentication_repository/phone_formatter.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/colors.dart';

class OnboardingTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final PhoneNumberFormatter? inputFormatter;

  const OnboardingTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    required this.prefixIcon,
    this.inputFormatter,
  });

  @override
  State<OnboardingTextFormField> createState() =>
      _OnboardingTextFormFieldState();
}

class _OnboardingTextFormFieldState extends State<OnboardingTextFormField> {
  late bool obscureText;

  @override
  void initState() {
    super.initState();
    // Initialize the obscureText based on whether the field is meant to be for passwords.
    obscureText = obscureText = widget.label.toLowerCase().contains("password");
  }

  void _togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: Scale.x(
                  15)), // Align icon with text field in case of error or multiple lines.
          child: IconInkResponse(
            icon: widget.prefixIcon,
            color: AppColors.green,
            size: Scale.x(18),
            onTap: () {},
          ),
        ),
        SizedBox(width: Scale.x(10)),
        Expanded(
          child: TextFormField(
            style: const TextStyle(
              fontFamily: 'Raleway',
            ),
            controller: widget.controller,
            cursorColor: AppColors.green,
            obscureText: obscureText,
            validator: widget.validator,
            inputFormatters:
                widget.inputFormatter != null ? [widget.inputFormatter!] : null,
            decoration: InputDecoration(
              hintText: widget.label,
              hintStyle: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: Scale.x(14),
                color: AppColors.darkerGrey,
              ),
              labelStyle: const TextStyle(
                  color: AppColors.navy, fontFamily: 'Open Sans'),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        SizedBox(width: Scale.x(10)),
        Padding(
            padding: EdgeInsets.only(
                top: Scale.x(14),
                right: Scale.x(
                    10)), // Align icon with text field in case of error or multiple lines.
            child: widget.label.toLowerCase().contains("password")
                ? IconInkResponse(
                    icon: obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.navy,
                    size: Scale.x(22),
                    onTap: _togglePasswordVisibility,
                  )
                : null),
      ],
    );
  }
}

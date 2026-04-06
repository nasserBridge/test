import 'package:bridgeapp/src/repository/authentication_repository/phone_formatter.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/colors.dart';

class UpdateTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final PhoneNumberFormatter? inputFormatter;

  const UpdateTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    required this.prefixIcon,
    this.inputFormatter,
  });

  @override
  State<UpdateTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<UpdateTextFormField> {
  late bool obscureText;

  @override
  void initState() {
    super.initState();
    // Initialize the obscureText based on whether the field is meant to be for passwords.
    obscureText =
        obscureText = widget.label!.toLowerCase().contains("password");
  }

  void _togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontFamily: 'Raleway'),
      controller: widget.controller,
      cursorColor: AppColors.green,
      obscureText: obscureText,
      validator: widget.validator,
      inputFormatters: widget.inputFormatter != null
          ? [widget.inputFormatter!]
          : null, // Apply input formatter if not null,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.label,
        hintStyle:
            const TextStyle(color: AppColors.navy, fontFamily: 'Open Sans'),
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, color: AppColors.navy),
        suffixIcon: widget.label!.toLowerCase().contains("password")
            ? IconButton(
                onPressed: _togglePasswordVisibility,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 22.5,
                  color: const Color.fromARGB(255, 144, 139, 139),
                ),
              )
            : null,
        labelStyle:
            const TextStyle(color: AppColors.navy, fontFamily: 'Open Sans'),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.green, width: 2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(width: 2, color: AppColors.green),
        ),
      ),
    );
  }
}

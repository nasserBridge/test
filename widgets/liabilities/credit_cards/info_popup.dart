import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:flutter/material.dart';

class InfoPopup {
  static void showInfoDialog({
    required BuildContext context,
    required String message,
    String buttonText = "Exit", // Optional button text with a default value
    VoidCallback? onButtonPressed, // Optional custom button action
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 30,
                    color: AppColors.navy,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizes.profileEdit,
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(
                        const Size(180, 15),
                      ),
                      side: WidgetStateProperty.resolveWith(
                        (states) => const BorderSide(color: AppColors.green),
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => AppColors.green,
                      ),
                      overlayColor: WidgetStateProperty.resolveWith(
                        (states) => AppColors.navy.withValues(alpha: 0.1),
                      ),
                    ),
                    onPressed: onButtonPressed ??
                        () {
                          Navigator.of(context).pop();
                        },
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

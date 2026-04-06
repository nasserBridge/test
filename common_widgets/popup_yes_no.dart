import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:flutter/material.dart';

class PopupYesNo {
  static void showInfoDialog(
    BuildContext context, {
    required String mainText,
    required VoidCallback onYesPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Set to false to not dismiss dialog by tapping outside of it
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mainText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w600,
                    fontSize: FontSizes.profileEdit,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateColor.resolveWith(
                            (states) => AppColors.green),
                        foregroundColor: WidgetStateColor.resolveWith(
                            (states) => AppColors.white),
                        overlayColor: WidgetStateColor.resolveWith(
                            (states) => AppColors.navy),
                      ),
                      onPressed: () {
                        onYesPressed();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Yes',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          )),
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                        side: WidgetStateBorderSide.resolveWith((states) =>
                            const BorderSide(color: AppColors.green)),
                        foregroundColor: WidgetStateColor.resolveWith(
                            (states) => AppColors.green),
                        overlayColor: WidgetStateColor.resolveWith(
                            (states) => AppColors.navy),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('No',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

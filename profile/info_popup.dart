import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class InfoPopup {
  static void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Scale.x(20.0))),
          child: SingleChildScrollView(
            // Wrap with SingleChildScrollView
            child: Padding(
              padding: EdgeInsets.all(Scale.x(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 30,
                    color: AppColors.navy,
                  ),
                  SizedBox(height: Scale.x(20)),
                  Text(
                    'Changing authentication info is currently unsupported.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizes.profileEdit,
                    ),
                  ),
                  SizedBox(height: Scale.x(20)),
                  OutlinedButton(
                      style: ButtonStyle(
                        fixedSize: WidgetStateProperty.all(
                            Size(Scale.x(180), Scale.x(15))),
                        side: WidgetStateBorderSide.resolveWith((states) =>
                            const BorderSide(color: AppColors.green)),
                        foregroundColor: WidgetStateColor.resolveWith(
                            (states) => AppColors.green),
                        overlayColor: WidgetStateColor.resolveWith(
                            (states) => AppColors.navy),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Exit',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                            letterSpacing: Scale.x(1.5),
                          ))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

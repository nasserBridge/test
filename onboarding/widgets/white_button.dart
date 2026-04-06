import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/utils/scale.dart';

class WhiteButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  // Optional customizations
  final double horizontalPadding;
  final double verticalPadding;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final BorderRadius? borderRadius;

  const WhiteButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.horizontalPadding = 15,
    this.verticalPadding = 10,
    this.backgroundColor = AppColors.white,
    this.textColor = AppColors.navy,
    this.fontSize = 14,
    this.fontWeight = FontWeight.bold,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(Scale.x(15));

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 75, 75, 75).withAlpha(76),
            spreadRadius: Scale.x(5),
            blurRadius: Scale.x(7),
            offset: Offset(0, Scale.x(3)),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: Scale.x(horizontalPadding),
            vertical: Scale.x(verticalPadding),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: backgroundColor,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: Scale.x(fontSize),
            color: textColor,
            fontWeight: fontWeight,
            fontFamily: 'Open Sans',
          ),
        ),
      ),
    );
  }
}

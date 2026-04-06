import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class IconInkResponse extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? color;
  final double? size;
  final EdgeInsetsGeometry? padding;

  const IconInkResponse(
      {super.key,
      required this.icon,
      this.onTap,
      this.color,
      this.padding,
      this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: InkResponse(
        // don't show splash if Icon is null
        onTap: onTap,
        splashColor: icon == null ? null : AppColors.navy.withAlpha(51),
        radius: Scale.x(12),
        highlightColor:
            icon == null ? null : AppColors.navy.withAlpha(51), // stays briefly
        borderRadius: BorderRadius.circular(12),
        child: Icon(
          icon,
          color: color ?? AppColors.navy,
          // default or use provided size
          size: size ?? Scale.x(24.0),
        ),
      ),
    );
  }
}

import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class WhiteContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const WhiteContainer({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        //height: height, // null means it'll size to the child
        width: width ?? double.infinity, // Makes it full width
        margin:
            margin ?? EdgeInsets.only(left: Scale.x(30), right: Scale.x(30)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0D1B16),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x0A0D1B16),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ));
  }
}

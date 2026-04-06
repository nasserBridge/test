import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double? height;
  final double? width;
  const LoadingIndicator({
    this.height,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: Scale.x(120),
        width: width ?? double.infinity,
        child: Center(child: CircularProgressIndicator.adaptive()));
  }
}

import 'package:flutter/material.dart';

class Scale {
  static late double w;
  static const double _base = 430.0; //iphone 16 Pro Max

  static void init(BuildContext ctx) {
    w = MediaQuery.of(ctx).size.width;
  }

  static double x(double size) {
    final f = w / _base;
    return size * (f < 1.0 ? f : 1.0);
  }
}

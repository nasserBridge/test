import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.white,
          iconTheme: IconThemeData(
            size: Scale.x(28),
            color: AppColors.navy,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: .3),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ],
          )),
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: MyNoTransitionsBuilder(),
        TargetPlatform.iOS: MyNoTransitionsBuilder(),
      }),
      iconTheme: IconThemeData(
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: .75),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),

      //Remove Icon Splash effect
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData());

  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(
            color: AppColors.navy,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: .3),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ],
          )),
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: MyNoTransitionsBuilder(),
        TargetPlatform.iOS: MyNoTransitionsBuilder(),
      }),
      iconTheme: IconThemeData(
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: .75),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),

      //Remove Icon Splash effect
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData());
}

class MyNoTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // This custom builder returns the child without any transitions.
    return child;
  }
}

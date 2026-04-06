import 'dart:async';
import 'package:flutter/widgets.dart';

class AppLifecycleController with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  VoidCallback? onTimeout;
  
  AppLifecycleController({this.onTimeout}) {
    WidgetsBinding.instance.addObserver(this);
  }
  
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelTimer();
  }
  
  void _cancelTimer() => _inactivityTimer?.cancel();

  void resetTimer() {
    _cancelTimer();
    _inactivityTimer = Timer(const Duration(minutes: 5), () => onTimeout?.call());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      resetTimer();
    } else if (state == AppLifecycleState.resumed) {
      _cancelTimer();
    }
  }
}

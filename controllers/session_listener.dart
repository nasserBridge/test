import 'package:bridgeapp/src/features/authentication/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:get/get.dart';

class SessionTimeOut extends StatefulWidget {
  const SessionTimeOut({super.key,});

  @override
  State<SessionTimeOut> createState() => _SessionTimeOutState();
}

class _SessionTimeOutState extends State<SessionTimeOut> {
  final _controller = Get.put(ProfileController());
  Timer? _inactivityTimer;
  
  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 5), _logOutUser);
  }

  void _logOutUser() {
     _controller.logoutDelete();
  }

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
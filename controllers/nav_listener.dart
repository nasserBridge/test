import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavListeners extends GetxController {
  static NavListeners get instance =>
      Get.find(); // Singleton instance of the class repository.

  /// Controller for managing the main appbar.
  ///
  /// External classes can subscribe to [appBarStream] to receive updates when
  /// user is on a subpage or main page.
  final _appBarController =
      StreamController<bool>.broadcast(); // Create controller.
  Stream<bool> get appBarStream =>
      _appBarController.stream; // Expose the stream to external classes.

  void isOnMain(bool trueorfalse) {
    _appBarController.add(trueorfalse);
  }

  /// Controller for managing the main appbar.
  ///
  /// External classes can subscribe to [popStream] to receive updates when
  /// user is on a subpage or main page.

  final _popController =
      StreamController<int>.broadcast(); // Create controller.
  Stream<int> get popStream =>
      _popController.stream; // Expose the stream to external classes.

  void popTilIndexRoute(int index, context) {
    Navigator.of(context).pop(); // Cancel
    _popController.add(index);
  }

  // Make demoBool observable
  var demoBool = true.obs;
}

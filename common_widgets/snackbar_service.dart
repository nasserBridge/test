import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarService {
  static void show(String message, {bool isError = false}) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? const Color.fromARGB(255, 212, 72, 62) : const Color.fromARGB(255, 120, 196, 165),
        margin: const EdgeInsets.all(15),
        borderRadius: 20,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      ),
    );
  }
}

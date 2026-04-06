import 'dart:async';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/accounts_controller.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/url.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';

class RemoveAccountRepo extends GetxController {
  static RemoveAccountRepo get instance => Get.find();

  final String _uri = getUrlForUser();
  final Future<String?> _authToken =
      AuthenticationRepository.instance.getIdToken();
  final _controller = Get.find<AccountsController>();

  void removeaccount(String accountID) async {
    try {
      _controller.updatingBalances.value = true;
      String apiVersion = getAPIVersion();
      String? token = await _authToken;
      final headers = {
        'Content-Type': 'application/json', // Content type
        'Authorization': 'Bearer $token', // Authentication token
        'Version': apiVersion,
      };
      final Map<String, String?> body = {
        "account_id": accountID,
      };

      final response = await http.post(Uri.parse('$_uri/removeaccount'),
          headers: headers, body: jsonEncode(body));

      if (response.statusCode == 426) {
        if (response.statusCode == 426) {
          SnackbarService.show(
            'Please update your app to the latest version.',
            isError: true,
          );
        }
      }

      if (response.statusCode == 200) {
        _controller.updatingBalances.value = false;
      }

      if (response.statusCode != 200) {
        SnackbarService.show(
          'Failed to remove account.',
          isError: true,
        );
        throw Exception(
            'Failed to remove account. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _controller.updatingBalancesFailed.value = true;
      _controller.updatingBalances.value = false;
      debugPrint("Error sending data to server path 'masterfile': $e");
    }
  }
}

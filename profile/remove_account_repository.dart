import 'dart:convert';
import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:bridgeapp/src/constants/url.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// Repository for removing linked bank accounts.
///
/// This class handles the deletion of bank accounts by making authenticated
/// API requests to the server to remove access tokens and account data.
class RemoveAccountRepo extends GetxController {
  static RemoveAccountRepo get instance => Get.find();

  /// Removes a bank account by its account ID.
  ///
  /// Makes an authenticated DELETE request to the server to remove the
  /// specified account and its associated access tokens.
  ///
  /// @param accountId The unique identifier of the account to remove
  /// @throws Exception if the deletion fails
  Future<void> removeaccount(String accountId) async {
    try {
      // Retrieve the user's authentication token
      String? token = await AuthenticationRepository.instance.getIdToken();

      if (token == null) {
        throw Exception('Authentication token not available');
      }

      String uri = getUrlForUser();
      String apiVersion = getAPIVersion();

      // Create http headers
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Version': apiVersion,
      };

      // Request body with account ID to remove
      final Map<String, dynamic> body = {
        "account_id": accountId,
      };

      // Make DELETE request to the server
      final response = await http.delete(
        Uri.parse('$uri/removeaccount'),
        headers: headers,
        body: jsonEncode(body),
      );

      // Handle version mismatch
      if (response.statusCode == 426) {
        SnackbarService.show(
          'Please update your app to the latest version.',
          isError: true,
        );
        throw Exception('App version outdated');
      }

      // Handle successful deletion
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check if the response indicates success
        if (responseData['success'] == true) {
          return;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to remove account');
        }
      }
      // Handle other error codes
      else if (response.statusCode == 404) {
        throw Exception('Account not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please log in again');
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Failed to remove account';
        throw Exception(errorMessage);
      }
    } catch (error, stackTrace) {
      LogUtil.error(
        'Error removing account:',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Removes multiple bank accounts by their account IDs.
  ///
  /// This is a batch operation that attempts to remove multiple accounts
  /// in a single API call for better performance.
  ///
  /// @param accountIds List of account IDs to remove
  /// @returns Map with 'success' list and 'failed' list of account IDs
  Future<Map<String, List<String>>> removeMultipleAccounts(
    List<String> accountIds,
  ) async {
    try {
      // Retrieve the user's authentication token
      String? token = await AuthenticationRepository.instance.getIdToken();

      if (token == null) {
        throw Exception('Authentication token not available');
      }

      String uri = getUrlForUser();
      String apiVersion = getAPIVersion();

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Version': apiVersion,
      };

      final Map<String, dynamic> body = {
        "account_ids": accountIds,
      };

      final response = await http.delete(
        Uri.parse('$uri/removeaccounts'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 426) {
        SnackbarService.show(
          'Please update your app to the latest version.',
          isError: true,
        );
        throw Exception('App version outdated');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return {
          'success': List<String>.from(responseData['success'] ?? []),
          'failed': List<String>.from(responseData['failed'] ?? []),
        };
      } else {
        throw Exception('Failed to remove accounts');
      }
    } catch (error, stackTrace) {
      LogUtil.error(
        'Error removing multiple accounts:',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

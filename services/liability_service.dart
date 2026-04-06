import 'package:bridgeapp/src/constants/url.dart';
import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/link_tokens/consents_link_token_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LiabilityService {
  String refreshAccountID;
  LiabilityService({required this.refreshAccountID});

  Future<void> plaidRequest() async {
    try {
      // Retrieve the user's authentication token.
      String? token = await AuthenticationRepository.instance
          .getIdToken(); // Wait until auth token is created before proceeding.
      String uri = getUrlForUser(); // URI for making API requests to server.
      String apiVersion = getAPIVersion();

      // Create http header.
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include authentication token.
        'Version': apiVersion,
      };

      final Map<String, dynamic> body = {
        "refresh_account": refreshAccountID,
      };

      // Make a post request to the server, wait for response before proceeding.
      final response = await http.post(
        Uri.parse('$uri/liabilities'), // Define api route.
        headers: headers, // Include header.
        body: jsonEncode(body),
      );

      if (response.statusCode == 426) {
        SnackbarService.show(
          'Please update your app to the latest version.',
          isError: true,
        );
      }
      if (jsonDecode(response.body)['unhealthy_link_token'] != null) {
        final repoConsentLinkTokenRepo =
            Get.find<ConsentsLinkTokenController>(tag: 'accountLevel');
        repoConsentLinkTokenRepo.consentsTokenList(
            [jsonDecode(response.body)['unhealthy_link_token']],
            refreshAccountID);
      }
    } catch (e) {
      SnackbarService.show('Error refreshing payment details, try again.',
          isError: true);
      LogUtil.error(e.toString());
    }
  }
}

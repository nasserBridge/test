import 'dart:async';
import 'package:bridgeapp/src/features/authentication/screens/accounts/models/server_response_model.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bridgeapp/src/constants/url.dart';

class BalanceService {
  Future<ServerResponseModel> plaidRequest(String? refreshAccount) async {
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
        "refresh_account": refreshAccount,
      };

      // Make a post request to the server, wait for response before proceeding.
      final response = await http
          .post(
            Uri.parse('$uri/checkaccesstokens'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
      final responseBody = jsonDecode(response.body);

      return ServerResponseModel(
        unhealthyLinkTokens: responseBody['unhealthy_link_tokens'],
        allUnhealthy: responseBody['all_unhealthy'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }
}

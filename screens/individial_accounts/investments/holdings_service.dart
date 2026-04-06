import 'dart:convert';
import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/link_tokens/consents_link_token_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_model.dart';
import 'package:bridgeapp/src/utils/normalize.dart';
import 'package:http/http.dart' as http;
import 'package:bridgeapp/src/constants/url.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:get/get.dart';

class HoldingsService {
  /// Convert string booleans from backend to actual booleans
  bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    return null;
  }

  /// Converts individual holding object to HoldingsModel
  /// Handles data normalization and type conversion
  HoldingsModel toModel(Object data) {
    final Map<String, dynamic> raw = normalizeMap(data);

    // Convert string booleans to actual booleans
    final Map<String, dynamic> normalized = Map.from(raw);
    normalized['fixed_income'] = _parseBool(raw['fixed_income']);
    normalized['is_cash_equivalent'] = _parseBool(raw['is_cash_equivalent']);
    normalized['option_contract'] = _parseBool(raw['option_contract']);

    return HoldingsModel.fromMap(normalized);
  }

  /// Makes a POST request to fetch investments/holdings data from the server
  Future<void> plaidRequest(String accountID, bool refreshBool) async {
    try {
      final userUID = AuthenticationRepository.instance.firebaseUser.value?.uid;
      String? token = await AuthenticationRepository.instance.getIdToken();
      String uri = getUrlForUser();
      String apiVersion = getAPIVersion();

      // Create http header
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Version': apiVersion,
      };

      final Map<String, dynamic> body = {
        "user_id": userUID,
        "account_id": accountID,
        "refresh": refreshBool,
      };

      // Make a POST request to the server
      final response = await http.post(
        Uri.parse('$uri/investments'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 426) {
        SnackbarService.show(
          'Please update your app to the latest version.',
          isError: true,
        );
        return;
      }

      // Handle unhealthy link tokens
      final responseBody = jsonDecode(response.body);
      if (responseBody['unhealthy_link_token'] != null) {
        final consentsLinkTokenRepo =
            Get.find<ConsentsLinkTokenController>(tag: 'accountLevel');
        consentsLinkTokenRepo.consentsTokenList(
            [responseBody['unhealthy_link_token']], accountID);
      }

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }

      LogUtil.info('InvestmentsService: Successfully refreshed holdings data');
    } catch (e, stackTrace) {
      LogUtil.error('Error in InvestmentsService.plaidRequest',
          error: e, stackTrace: stackTrace);
      // Don't show snackbar here to avoid overlay issues
    }
  }
}

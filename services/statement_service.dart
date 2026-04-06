import 'dart:async';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bridgeapp/src/constants/url.dart';
import 'dart:io';

class StatementService {
  final String accountID;
  final String month;
  final String institution;

  StatementService({
    required this.accountID,
    required this.month,
    required this.institution,
  });

// Request PDF statement, save it to a temp file, and return the file path
  Future<http.Response> plaidRequest(bool initialRequest) async {
    try {
      String? token = await AuthenticationRepository.instance.getIdToken();
      final String apiVersion = getAPIVersion();

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Version': apiVersion,
      };

      final Map<String, dynamic> body = {
        "account_id": accountID,
        'date': month,
        'initial_request': initialRequest
      };

      final String uri = getUrlForUser();

      final response = await http.post(
        Uri.parse('$uri/statements'),
        headers: headers,
        body: jsonEncode(body),
      );
      // ✅ Force failure into catch if not 200
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Copies a temp PDF into Documents/Bridge/Statements and returns saved path.
  Future<void> saveToDevice(String localFilePath) async {
    try {
      final bytes = await File(localFilePath).readAsBytes();

      await FilePicker.platform.saveFile(
          fileName: '$institution $month.pdf',
          bytes: bytes,
          type: FileType.any,
          allowedExtensions: ['pdf']);
    } catch (e) {
      rethrow;
    }
  }
}

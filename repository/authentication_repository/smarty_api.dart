import 'dart:convert';
import 'package:bridgeapp/src/features/authentication/models/update_user_model.dart';
import 'package:bridgeapp/src/features/authentication/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SmartyApi extends GetxController {
  static SmartyApi get instance => Get.find();
  final String _baseUrl = 'https://us-street.api.smarty.com';
  final String _embeddedKey = '193825293629323271';

  Future<String?> checkAddress(UserModel user) async {
    try {
      final formattedAddress = formatAddress(user);
      final url = Uri.parse(
          '$_baseUrl/street-address?street=$formattedAddress&key=$_embeddedKey');
      final headers = {
        'Referer': 'https://appserver.bridgebanking.info',
        'X-Api-Key': _embeddedKey,
      };
      final response = await http.get(url, headers: headers);

      final rdi = jsonDecode(response.body)[0]['metadata']['rdi'];
      return rdi;
    } catch (e) {
      // Do nothing, let the exception propagate
    }
    return null;
  }

  String formatAddress(UserModel user) {
    // Remove any spaces from zipcode
    String sanitizedZipcode = user.zipcode.replaceAll(' ', '');

    // Build the input string with sanitized zipcode
    final input =
        '${user.address1}${user.address2} ${user.city} ${user.state} $sanitizedZipcode';

    // Split the input string by spaces
    List<String> parts = input.split(' ');

    // Join the parts using '+'
    String formattedAddress = parts.join('+');
    debugPrint(formattedAddress);
    return formattedAddress;
  }

  Future<String?> checkAddress2(UpdateAddressUserModel user) async {
    try {
      final formattedAddress = formatAddress2(user);
      final url = Uri.parse(
          '$_baseUrl/street-address?street=$formattedAddress&key=$_embeddedKey');
      final headers = {
        'Referer': 'https://appserver.bridgebanking.info',
        'X-Api-Key': _embeddedKey,
      };
      final response = await http.get(url, headers: headers);

      final rdi = jsonDecode(response.body)[0]['metadata']['rdi'];
      return rdi;
    } catch (e) {
      // Do nothing, let the exception propagate
    }
    return null;
  }

  String formatAddress2(UpdateAddressUserModel user) {
    // Split the input string by spaces
    final input =
        '${user.address1}${user.address2} ${user.city} ${user.state} ${user.zipcode}';
    List<String> parts = input.split(' ');

    // Join the parts using '+'
    String formattedAddress = parts.join('+');
    debugPrint(formattedAddress);
    return formattedAddress;
  }
}

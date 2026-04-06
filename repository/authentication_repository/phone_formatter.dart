import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If the new value is shorter than the old value, return newValue
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // Check if the text already starts with '+'
    final bool startsWithPlus = newValue.text.startsWith('+');

    // Remove all characters that are not digits
    final unformattedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Determine the maximum length of the phone number
    final maxLength = startsWithPlus ? 11 : 10;

    // Cap the length of the unformatted text
    final cappedText = unformattedText.length <= maxLength
        ? unformattedText
        : unformattedText.substring(0, maxLength);

    // Format the phone number as '+1 (XXX) XXX-XXXX'
    var formattedText = startsWithPlus ? '+' : '+1 ';
    for (var i = 0; i < cappedText.length; i++) {
      if ((i == 0 && !startsWithPlus) || i == 1) {
        formattedText += '(';
      } else if ((i == 3 && !startsWithPlus) || i == 4) {
        formattedText += ') ';
      } else if ((i == 6 && !startsWithPlus) || i == 7) {
        formattedText += '-';
      }
      formattedText += cappedText[i];
    }

    // If the formatted text starts with '+1' and there's no space after it, add it
    if (formattedText.startsWith('+1') && !formattedText.startsWith('+1 ')) {
      formattedText = formattedText.replaceFirst('+1', '+1 ');
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

import 'package:intl/intl.dart';

String text(String? value) => (value == null || value.isEmpty) ? "NA" : value;

String? currency(double? value) {
  if (value == null) return null;
  final formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  return formatter.format(value);
}

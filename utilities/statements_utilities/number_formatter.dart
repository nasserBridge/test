num? toNum(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[^0-9.\-]'), '');
  return cleaned.isEmpty ? null : num.tryParse(cleaned);
}

String numToText(num v) {
  final d = v.toDouble();
  return d == d.roundToDouble()
      ? d.toStringAsFixed(0)
      : d.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
}

String fmtMoney(num v) {
  final n = v.abs();
  final sign = v < 0 ? '-' : '';
  final parts = n.toStringAsFixed(2).split('.');
  final whole =
      parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return '$sign\$$whole.${parts[1]}';
}

String fmtMonths(int m) {
  final years = m ~/ 12;
  final months = m % 12;
  if (years == 0) return '$months months';
  if (months == 0) return '$years years';
  return '$years years, $months months';
}

String fmtMonthsSaved(int m) {
  if (m <= 0) return '0';
  final y = m ~/ 12;
  final mo = m % 12;
  if (y > 0 && mo > 0) return '$m ($y y $mo m)';
  if (y > 0) return '$m ($y y)';
  return '$m';
}

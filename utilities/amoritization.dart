class AmortizationResult {
  final int months;
  final double totalInterest;
  final bool isValid;

  const AmortizationResult({
    required this.months,
    required this.totalInterest,
    required this.isValid,
  });
}

double standardPayment({
  required double principal,
  required double monthlyRate,
  required int termMonths,
}) {
  if (termMonths <= 0) return 0;
  if (monthlyRate == 0) return principal / termMonths;

  final r = monthlyRate;
  final n = termMonths;
  final powVal = _pow(1 + r, n);
  final denom = 1 - 1 / powVal;
  return denom == 0 ? 0 : principal * r / denom;
}

AmortizationResult simulateSchedule({
  required double principal,
  required double monthlyRate,
  required double payment,
  required int maxMonths,
}) {
  var balance = principal;
  var totalInterest = 0.0;
  var month = 0;

  final minPayment = monthlyRate == 0
      ? (principal / maxMonths).clamp(1.0, double.infinity)
      : (principal * monthlyRate) + 1.0;

  final pmt = payment < minPayment ? minPayment : payment;

  while (balance > 0 && month < maxMonths) {
    final interest = balance * monthlyRate;
    var principalPay = pmt - interest;

    if (principalPay <= 0) principalPay = 1.0;
    if (principalPay > balance) principalPay = balance;

    balance -= principalPay;
    totalInterest += interest;
    month++;

    if (balance <= 0.01) break;
  }

  return AmortizationResult(
    months: month,
    totalInterest: totalInterest,
    isValid: balance <= 0,
  );
}

double _pow(double base, int exp) {
  var result = 1.0;
  var b = base;
  var e = exp;
  while (e > 0) {
    if (e & 1 == 1) result *= b;
    b *= b;
    e >>= 1;
  }
  return result;
}

import 'package:bridgeapp/src/features/authentication/screens/accounts/utilities/amoritization.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/utilities/statements_utilities/number_formatter.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/models/mortgage_model.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';

class PaymentCalculator extends StatefulWidget {
  final MortgageModel? mortgageData;

  const PaymentCalculator({
    super.key,
    this.mortgageData,
  });

  @override
  State<PaymentCalculator> createState() => _PaymentCalculatorState();
}

class _PaymentCalculatorState extends State<PaymentCalculator> {
  final _principalCtrl = TextEditingController();
  final _aprCtrl = TextEditingController();
  final _termCtrl = TextEditingController();
  final _extraCtrl = TextEditingController();

  String? _error;
  double? _calculatedPayment;
  int? _baseMonths;
  double? _baseInterest;
  int? _newMonths;
  double? _newInterest;

  @override
  void initState() {
    super.initState();
    _seedInputsFromMortgage();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
  }

  @override
  void dispose() {
    _principalCtrl.dispose();
    _aprCtrl.dispose();
    _termCtrl.dispose();
    _extraCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Seed inputs from MortgageModel
  // ---------------------------------------------------------------------------

  void _seedInputsFromMortgage() {
    if (widget.mortgageData == null) {
      // print('DEBUG: No mortgage data provided');
      return;
    }

    final mortgage = widget.mortgageData!;
    // print('DEBUG: Seeding calculator with mortgage data');

    // Set APR
    if (mortgage.interestRatePercentage != null) {
      _aprCtrl.text = numToText(mortgage.interestRatePercentage!);
      // print('DEBUG: Set APR: ${mortgage.interestRatePercentage}');
    } else {
      // print('DEBUG: No APR available');
    }

    // Calculate remaining term - try multiple strategies
    int? remainingMonths;

    // print('DEBUG: Starting term calculation...');
    // print('DEBUG: Maturity date: ${mortgage.maturityDate}');
    // print('DEBUG: Loan term: ${mortgage.loanTerm}');
    // print('DEBUG: Origination date: ${mortgage.originationDate}');

    // Strategy 1: Calculate from maturity date
    if (mortgage.maturityDate != null) {
      remainingMonths =
          _calculateRemainingMonthsFromDate(mortgage.maturityDate!);
      if (remainingMonths != null) {
        //print('DEBUG: ✓ Strategy 1 succeeded: $remainingMonths months');
      } else {
        //print('DEBUG: ✗ Strategy 1 failed');
      }
    }

    // Strategy 2: Extract from loan term string if maturity date failed
    if (remainingMonths == null && mortgage.loanTerm != null) {
      remainingMonths = _extractMonthsFromLoanTerm(mortgage.loanTerm!);
      if (remainingMonths != null) {
        //print('DEBUG: ✓ Strategy 2 succeeded: $remainingMonths months (from loan term)');
      } else {
        //print('DEBUG: ✗ Strategy 2 failed');
      }
    }

    // Strategy 3: Calculate from origination date and loan term
    if (remainingMonths == null &&
        mortgage.originationDate != null &&
        mortgage.loanTerm != null) {
      remainingMonths = _calculateRemainingFromOrigination(
        mortgage.originationDate!,
        mortgage.loanTerm!,
      );
      if (remainingMonths != null) {
        //print('DEBUG: ✓ Strategy 3 succeeded: $remainingMonths months (from origination)');
      } else {
        //print('DEBUG: ✗ Strategy 3 failed');
      }
    }

    if (remainingMonths != null && remainingMonths > 0) {
      _termCtrl.text = remainingMonths.toString();
      //print('DEBUG: Final remaining term set: $remainingMonths months');
    } else {
      //print('DEBUG: ✗ All strategies failed to calculate remaining months');
    }

    // Set remaining balance
    if (mortgage.originationPrincipalAmount != null) {
      _principalCtrl.text = numToText(mortgage.originationPrincipalAmount!);
      //print('DEBUG: Set principal: ${mortgage.originationPrincipalAmount}');
    } else {
      //print('DEBUG: No principal amount available');
    }

    //print('DEBUG: Seeding complete');
  }

  /// Calculate remaining months from maturity date
  /// Handles format: MM/DD/YYYY (e.g., "07/31/2045")
  int? _calculateRemainingMonthsFromDate(String maturityDate) {
    try {
      DateTime? maturity;

      // Primary format: MM/DD/YYYY (your data format)
      if (maturityDate.contains('/')) {
        final parts = maturityDate.split('/');
        if (parts.length == 3) {
          final month = int.tryParse(parts[0].trim());
          final day = int.tryParse(parts[1].trim());
          final year = int.tryParse(parts[2].trim());

          if (month != null && day != null && year != null) {
            // Handle 2-digit years
            final fullYear = year < 100 ? 2000 + year : year;
            maturity = DateTime(fullYear, month, day);
            //print('DEBUG: Created DateTime: $maturity');
          }
        }
      }

      // Fallback: ISO format (YYYY-MM-DD)
      if (maturity == null && maturityDate.contains('-')) {
        maturity = DateTime.tryParse(maturityDate);
        if (maturity != null) {}
      }

      if (maturity == null) {
        return null;
      }

      final now = DateTime.now();

      // Calculate months accurately
      final years = maturity.year - now.year;
      final months = maturity.month - now.month;
      final days = maturity.day - now.day;

      int totalMonths = (years * 12) + months;

      // Adjust if we haven't reached the day of the month yet
      if (days < 0) {
        totalMonths--;
      }

      return totalMonths > 0 ? totalMonths : null;
    } catch (e) {
      return null;
    }
  }

  /// Extract months from loan term string
  /// Handles formats: "30 year", "30 years", "360 months", "360"
  int? _extractMonthsFromLoanTerm(String loanTerm) {
    try {
      final trimmed = loanTerm.trim().toLowerCase();

      // Pattern 1: "30 year" or "30 years" (your data format)
      final yearMatch =
          RegExp(r'(\d+)\s*years?', caseSensitive: false).firstMatch(trimmed);
      if (yearMatch != null) {
        final years = int.tryParse(yearMatch.group(1) ?? '');
        if (years != null) {
          final months = years * 12;
          //print('DEBUG: Extracted $years years = $months months');
          return months;
        }
      }

      // Pattern 2: "360 months" or "360 month"
      final monthMatch =
          RegExp(r'(\d+)\s*months?', caseSensitive: false).firstMatch(trimmed);
      if (monthMatch != null) {
        final months = int.tryParse(monthMatch.group(1) ?? '');
        if (months != null) {
          //print('DEBUG: Extracted $months months');
          return months;
        }
      }

      // Pattern 3: Just a number "360"
      final numberMatch = RegExp(r'^(\d+)$').firstMatch(trimmed);
      if (numberMatch != null) {
        final num = int.tryParse(numberMatch.group(1) ?? '');
        // If it's a reasonable number of months (1-720 = 60 years max)
        if (num != null && num > 0 && num <= 720) {
          //print('DEBUG: Extracted plain number: $num months');
          return num;
        }
      }

      //print('DEBUG: No pattern matched');
    } catch (e) {
      //print('DEBUG: Exception extracting months from loan term: $e');
    }

    return null;
  }

  /// Calculate remaining months from origination date and loan term
  /// Handles format: "08/01/2015" and "30 year"
  int? _calculateRemainingFromOrigination(
      String originationDate, String loanTerm) {
    //print('DEBUG: Calculating from origination: "$originationDate" + "$loanTerm"');

    try {
      // Parse origination date (MM/DD/YYYY format)
      DateTime? origination;

      if (originationDate.contains('/')) {
        final parts = originationDate.split('/');
        if (parts.length == 3) {
          final month = int.tryParse(parts[0].trim());
          final day = int.tryParse(parts[1].trim());
          final year = int.tryParse(parts[2].trim());

          if (month != null && day != null && year != null) {
            final fullYear = year < 100 ? 2000 + year : year;
            origination = DateTime(fullYear, month, day);
            //print('DEBUG: Parsed origination: $origination');
          }
        }
      } else {
        origination = DateTime.tryParse(originationDate);
      }

      if (origination == null) {
        //print('DEBUG: Failed to parse origination date');
        return null;
      }

      // Extract total term months
      final totalMonths = _extractMonthsFromLoanTerm(loanTerm);
      if (totalMonths == null) {
        //print('DEBUG: Failed to extract term months');
        return null;
      }

      // Calculate maturity date
      final maturityYear = origination.year + (totalMonths ~/ 12);
      final maturityMonth = origination.month + (totalMonths % 12);
      final maturity = DateTime(maturityYear, maturityMonth, origination.day);

      //print('DEBUG: Calculated maturity: $maturity');

      // Calculate remaining months
      final now = DateTime.now();
      final years = maturity.year - now.year;
      final months = maturity.month - now.month;
      final days = maturity.day - now.day;

      int remainingMonths = (years * 12) + months;
      if (days < 0) {
        remainingMonths--;
      }

      //print('DEBUG: Calculated remaining: $remainingMonths months');
      return remainingMonths > 0 ? remainingMonths : null;
    } catch (e) {
      //print('DEBUG: Exception calculating from origination: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Core calculation
  // ---------------------------------------------------------------------------

  void _recompute() {
    final principal = toNum(_principalCtrl.text)?.toDouble();
    final aprInput = toNum(_aprCtrl.text)?.toDouble();
    final termMonths = int.tryParse(_termCtrl.text.trim());
    final extra = toNum(_extraCtrl.text)?.toDouble() ?? 0;

    if (principal == null || principal <= 0) {
      return _setError('Enter a positive remaining balance.');
    }
    if (termMonths == null || termMonths <= 0) {
      return _setError('Enter remaining term in months.');
    }
    if (aprInput == null || aprInput < 0) {
      return _setError('Enter APR (e.g. 3.99).');
    }

    final aprPct = aprInput <= 1 ? aprInput * 100 : aprInput;
    final monthlyRate = (aprPct / 100) / 12;

    // Calculate the monthly payment
    final payment = standardPayment(
      principal: principal,
      monthlyRate: monthlyRate,
      termMonths: termMonths,
    );

    final base = simulateSchedule(
      principal: principal,
      monthlyRate: monthlyRate,
      payment: payment,
      maxMonths: termMonths * 2,
    );

    final withExtra = simulateSchedule(
      principal: principal,
      monthlyRate: monthlyRate,
      payment: payment + extra,
      maxMonths: termMonths * 2,
    );

    if (!base.isValid || !withExtra.isValid) {
      return _setError('Those numbers do not quite work.');
    }

    setState(() {
      _error = null;
      _calculatedPayment = payment;
      _baseMonths = base.months;
      _baseInterest = base.totalInterest;
      _newMonths = withExtra.months;
      _newInterest = withExtra.totalInterest;
    });
  }

  void _setError(String msg) {
    setState(() {
      _error = msg;
      _calculatedPayment = null;
      _baseMonths = _newMonths = null;
      _baseInterest = _newInterest = null;
    });
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final hasResults =
        _baseMonths != null && _baseInterest != null && _newMonths != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'See how extra payments can speed up your payoff.',
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: FontSizes.transDate,
            color: const Color.fromARGB(255, 99, 99, 99),
          ),
        ),
        const SizedBox(height: 12),
        CalculatorCard(child: _buildInputs()),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
        ],
        const SizedBox(height: 16),
        if (hasResults) CalculatorCard(child: _buildResults()),
        const SizedBox(height: 12),
        _buildDisclaimer(),
      ],
    );
  }

  Widget _buildInputs() {
    return Column(
      children: [
        _compactInputRow('Remaining balance', _principalCtrl, prefix: '\$'),
        _compactInputRow('APR', _aprCtrl, suffix: '%'),
        _compactInputRow('Remaining term', _termCtrl, suffix: 'months'),
        if (_calculatedPayment != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Monthly payment',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  fmtMoney(_calculatedPayment!),
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        const Divider(height: 24),
        _compactInputRow('Extra payment every month', _extraCtrl, prefix: '\$'),
      ],
    );
  }

  Widget _compactInputRow(
    String label,
    TextEditingController controller, {
    String? prefix,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: controller,
              onChanged: (_) => _recompute(),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                prefixText: prefix,
                suffixText: suffix,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.navy, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final extra = toNum(_extraCtrl.text)?.toDouble() ?? 0;
    final hasExtraPayment = extra > 0;

    final monthsSaved =
        hasExtraPayment ? (_baseMonths! - _newMonths!).clamp(0, 10000) : 0;
    final interestSaved =
        hasExtraPayment ? (_baseInterest! - _newInterest!).clamp(0, 1e12) : 0.0;

    return Column(
      children: [
        _resultRow('Payoff time', fmtMonths(_baseMonths!)),
        _resultRow('Total interest', fmtMoney(_baseInterest!)),
        const Divider(height: 24),
        hasExtraPayment
            ? _resultRow('New payoff time', fmtMonths(_newMonths!))
            : _resultRow('New payoff time', 'Enter extra payment',
                isError: true),
        hasExtraPayment
            ? _resultRow('New interest', fmtMoney(_newInterest!))
            : _resultRow('New interest', 'Enter extra payment', isError: true),
        const Divider(height: 24),
        _resultRow('Months saved',
            hasExtraPayment ? fmtMonthsSaved(monthsSaved) : '-'),
        _resultRow(
            'Interest saved', hasExtraPayment ? fmtMoney(interestSaved) : '-'),
      ],
    );
  }

  Widget _resultRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isError ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Payment amounts may not include PMI and property taxes if escrowed by your servicer. Data is provided directly by your financial institution and calculations are estimates.',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 12,
                color: Colors.blue.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorCard extends StatelessWidget {
  final Widget child;
  const CalculatorCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

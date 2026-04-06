///This file contains the utility functions for implenting logic into
/// the filter button for each category.
library;

/// Parses a percentage string like "3.60%" or "1.5% - 4.0%" into a double.
/// Returns the first number found, or 0.0 if none.
double _parseApy(String? apy) {
  if (apy == null || apy.isEmpty) return 0.0;
  final match = RegExp(r'\d+(\.\d+)?').firstMatch(apy);
  return match != null ? double.tryParse(match.group(0)!) ?? 0.0 : 0.0;
}

/// This functions filters the checking accounts based on the selected filters.
/// Facilitates the filter button.
List<Map<String, dynamic>> filterCheckings({
  required List<Map<String, dynamic>> institutions,
  required Map<String, Map<String, bool>> checkingFiltersData,
}) {
  final feeWaiverSelections = checkingFiltersData['Fee Waiver Options']
          ?.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList() ??
      [];

  final preferenceSelections = checkingFiltersData['Preferences']
          ?.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList() ??
      [];

  if (feeWaiverSelections.isEmpty && preferenceSelections.isEmpty) {
    return institutions;
  }

  return institutions.where((acc) {
    final waivers = acc['Fee Waiver Options'] ?? {};
    final apy = acc['APY'];
    final bonus = acc['Bonus Offer'];
    final min = acc['Min Opening Balance'];
    final overdraft = acc['Overdraft Fee'];
    final tiered = acc['Tiered Relationship Program'];

    final matchesAllFeeWaiver = feeWaiverSelections.every((opt) {
      final val = waivers[opt];
      return val is bool ? val : val != null;
    });

    final matchesAllOtherOptions = preferenceSelections.every((opt) {
      switch (opt) {
        case 'Bonus Offer':
          return bonus != null && bonus != '\$0';
        case 'Earns Interest':
          return _parseApy(apy?.toString()) > 0.0;
        case '\$0 Opening Balance':
          return min == '\$0';
        case 'No Overdraft Fee':
          return overdraft == '\$0';
        case 'Tiered Relationship Program':
          return tiered != null;
        default:
          return false;
      }
    });

    return matchesAllFeeWaiver && matchesAllOtherOptions;
  }).toList();
}

/// This functions filters the savings accounts based on the selected filters.
/// Facilitates the filter button.
List<Map<String, dynamic>> filterSavings({
  required List<Map<String, dynamic>> institutions,
  required Map<String, Map<String, bool>> savingsFiltersData,
}) {
  final feeWaiverSelections = savingsFiltersData['Fee Waiver Options']
          ?.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList() ??
      [];

  final preferenceSelections = savingsFiltersData['Preferences']
          ?.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList() ??
      [];

  if (feeWaiverSelections.isEmpty && preferenceSelections.isEmpty) {
    return institutions;
  }

  return institutions.where((acc) {
    final waivers = acc['Fee Waiver Options'] ?? {};
    final apy = acc['APY'];
    final monthlyfee = acc['Monthly Maintenance Fee'];
    final min = acc['Min Opening Balance'];
    final tiered = acc['Tiered Relationship Program'];

    final matchesAllFeeWaiver = feeWaiverSelections.every((opt) {
      final val = waivers[opt];
      return val is bool ? val : val != null;
    });

    final matchesAllOtherOptions = preferenceSelections.every((opt) {
      switch (opt) {
        case 'No Monthly Fee':
          return monthlyfee == '\$0';
        case 'High Yield APY':
          return _parseApy(apy?.toString()) >= 1.0;
        case '\$0 Opening Balance':
          return min == '\$0';
        case 'Tiered Relationship Program':
          return tiered != null;
        default:
          return false;
      }
    });

    return matchesAllFeeWaiver && matchesAllOtherOptions;
  }).toList();
}

List<Map<String, dynamic>> filterCreditCards({
  required List<Map<String, dynamic>> institutions,
  required Map<String, Map<String, bool>> creditcardsFiltersData,
}) {
  final preferenceSelections = creditcardsFiltersData['Preferences']
          ?.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList() ??
      [];

  final programSelections = creditcardsFiltersData['Program']
          ?.entries
          .where((e) => e.value)
          .map((e) => e.key.toLowerCase())
          .toList() ??
      [];

  if (preferenceSelections.isEmpty && programSelections.isEmpty) {
    return institutions;
  }

  return institutions.where((acc) {
    bool matchesPreferences = true;
    for (final opt in preferenceSelections) {
      switch (opt) {
        case 'Bonus Offer':
          if (acc['Bonus Offer'] == null || acc['Bonus Offer'] == '\$0') {
            matchesPreferences = false;
          }
          break;
        case 'No Annual Fee':
          final fee = acc['Annual Fee'] ?? '';
          if (!fee.contains('\$0')) {
            matchesPreferences = false;
          }
          break;
        case '0% APR':
          if (acc['Intro Purchases APR'] == null) {
            matchesPreferences = false;
          }
          break;
        case 'Balance Transfer':
          if (acc['Intro Balance Transfers APR'] == null) {
            matchesPreferences = false;
          }
          break;
      }
      if (!matchesPreferences) break;
    }

    final program = (acc['Program'] ?? '').toString().toLowerCase();
    final matchesProgram = programSelections.isEmpty ||
        programSelections.any((p) => program.contains(p));

    return matchesPreferences && matchesProgram;
  }).toList();
}

/// This functions filters the Auto Loans accounts based on the selected filters.
/// Facilitates the filter button.
List<Map<String, dynamic>> filterAutoLoans({
  required List<Map<String, dynamic>> institutions,
  required Map<String, Map<String, bool>> autoloansFiltersData,
}) {
  final loantypeSelections = autoloansFiltersData['Loan Type']
          ?.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList() ??
      [];

  final sellerSelections = autoloansFiltersData['Seller']
          ?.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList() ??
      [];

  final termSelections = autoloansFiltersData['Months Term']
          ?.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList() ??
      [];

  if (loantypeSelections.isEmpty &&
      sellerSelections.isEmpty &&
      termSelections.isEmpty) {
    return institutions;
  }

  return institutions.where((acc) {
    final matchesloantype = loantypeSelections.every((opt) {
      return acc['Account'] == opt;
    });

    final matchesseller = sellerSelections.every((opt) {
      return acc['Seller'] == opt;
    });

    final matchesTerms = termSelections.every((opt) {
      final terms = acc['Month Term Lengths']?.toString() ?? '';
      return terms.contains(opt.replaceAll(' Months', ''));
    });

    return matchesloantype && matchesseller && matchesTerms;
  }).toList();
}

/// This functions filters the investment accounts based on the selected filters.
/// Facilitates the filter button.
List<Map<String, dynamic>> filterInvestments({
  required List<Map<String, dynamic>> institutions,
  required Map<String, Map<String, bool>> investmentsFiltersData,
}) {
  final preferenceSelections = investmentsFiltersData['Preferences']
          ?.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList() ??
      [];

  final assetClassSelections = investmentsFiltersData['Asset Classes']
          ?.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList() ??
      [];

  if (preferenceSelections.isEmpty && assetClassSelections.isEmpty) {
    return institutions;
  }

  return institutions.where((acc) {
    final matchesPreferences = preferenceSelections.every((opt) {
      switch (opt) {
        case 'No Commission':
          return acc['Trade Commission'] == '\$0';
        case '\$0 Opening Balance':
          return acc['Min Opening Balance'] == '\$0';
        default:
          return false;
      }
    });

    final matchesAssetClasses = assetClassSelections.every((opt) {
      return acc[opt] == true;
    });

    return matchesPreferences && matchesAssetClasses;
  }).toList();
}

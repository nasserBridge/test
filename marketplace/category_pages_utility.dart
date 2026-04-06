Map<String, Map<String, bool>> checkingFilters = {
  'Other Options': {
    'Bonus Offer': false,
    'Earns Interest': false,
    '\$0 Opening Balance': false,
    'No Overdraft Fee': false,
    'Tiered Relationship Program': false,
  },
  'Fee Waiver': {
    'Direct Deposit': false,
    'Daily Balance': false,
    'Student': false,
    'Transaction Minimum': false,
    'Military': false,
    'Other': false,
  },
};

Map<String, Map<String, bool>> savingsFilters = {
  'Preferences': {
    'No Monthly Fee': false, // true if string is '\$0',
    'High Yield APY': false, // true if string is not '0.01%',
    '\$0 Opening Balance': false, // true if string is '\$0',
    'Tiered Relationship Program': false, // true if not null
  },
  'Fee Waiver Options': {
    'Daily Balance': false, //true if value is not null
    'Age': false, // true if value is not null
    'Linked Account': false, // true if boolean value is true
    'Military': false, // true if boolean value is true
    'Other': false, // true if boolean value is true
  },
};

Map<String, Map<String, bool>> creditcardsFilters = {
  'Preferences': {
    'Bonus Offer': false, // true if string is not '\$0',
    'No Annual Fee': false, // true if string includes '\$0',
    '0% APR': false, // true if Intro Purchases APR not null
    'Balance Transfer': false, // true if Intro Balance Transfers APR not null
  },
  'Program': {
    'Cash Back': false, // true if string includes the word 'Cash Back',
    'Points': false, // true if string includes the word 'Points',
    'Miles': false, // true if string includes the word 'Miles',
  },
};

Map<String, Map<String, bool>> autoloansFilters = {
  'Loan Type': {
    'New Car': false,
    'Used Car': false,
    'Refinance': false,
    'Lease Buyout': false,
  },
  'Seller': {
    'Dealership': false,
    'Private Party': false,
  },
};

Map<String, Map<String, bool>> investmentsFilters = {
  'Preferences': {'No Commission': false, '\$0 Opening Balance': false},
  'Asset Classes': {
    'Stocks': false,
    'Bonds': false,
    'ETFs': false,
    'Mutual Funds': false,
    'Options': false,
    'Crypto': false,
    'CDs': false,
    'Precious Metals': false,
    'International Markets': false,
    'Money Market': false,
    'Fixed Income': false,
    'Index Funds': false,
    'Futures': false,
    'Forex': false,
  },
};

///This filtering function is used in marketplace_category.dart to build a
///marketpalce page containing only checking accounts according to our predefined
///categeories.
Map<String, List<Map<String, dynamic>>> getFilteredCheckings(
    List<Map<String, dynamic>> institutions) {
  final Map<String, List<Map<String, dynamic>>> filtered = {};
  final seenAccounts = <String>{};

  checkingFilters.forEach((filterType, filters) {
    filters.forEach((filterKey, isEnabled) {
      final matches = institutions.where((institution) {
        var matches = false;

        if (filterType == 'Other Options') {
          final bonus = institution['Bonus Offer'];
          final apy = institution['APY'];
          final openingBalance = institution['Min Opening Balance'];
          final overdraftFee = institution['Overdraft Fee'];
          final tiered = institution['Tiered Relationship Program'];

          switch (filterKey) {
            case 'Bonus Offer':
              matches = bonus != null && bonus != '\$0';
              break;
            case 'Earns Interest':
              matches = apy != null && apy != '0%';
              break;
            case '\$0 Opening Balance':
              matches = openingBalance == '\$0';
              break;
            case 'No Overdraft Fee':
              matches = overdraftFee == '\$0';
              break;
            case 'Tiered Relationship Program':
              matches = tiered != null;
              break;
          }
        } else if (filterType == 'Fee Waiver') {
          final options = institution['Fee Waiver Options'];
          if (options != null && options.containsKey(filterKey)) {
            final value = options[filterKey];
            matches = value == true || value != null;
          }
        }

        return matches;
      }).where((inst) => seenAccounts.add(inst['Account'] as String)).toList();

      if (matches.isNotEmpty) {
        final title =
            filterType == 'Fee Waiver' ? '$filterKey Waiver' : filterKey;
        filtered[title] = matches;
      }
    });
  });
  return filtered;
}

Map<String, List<Map<String, dynamic>>> getFilteredSavings(
    List<Map<String, dynamic>> institutions) {
  final Map<String, List<Map<String, dynamic>>> filtered = {};
  final seenAccounts = <String>{};

  savingsFilters.forEach((filterType, filters) {
    filters.forEach((filterKey, isEnabled) {
      // Comment this out only if you want to include all filters by default
      // if (!isEnabled) return;

      final matches = institutions.where((institution) {
        bool matches = false;

        if (filterType == 'Preferences') {
          final fee = institution['Monthly Maintenance Fee']?.toString();
          final apy = institution['APY']?.toString();
          final opening = institution['Min Opening Balance']?.toString();
          final tiered = institution['Tiered Relationship Program'];

          switch (filterKey) {
            case 'No Monthly Fee':
              matches = fee == '\$0';
              break;
            case 'High Yield APY':
              matches = apy != null && apy != '0.01%';
              break;
            case '\$0 Opening Balance':
              matches = opening == '\$0';
              break;
            case 'Tiered Relationship Program':
              matches = tiered != null;
              break;
          }
        } else if (filterType == 'Fee Waiver Options') {
          final options = institution['Fee Waiver Options'] as Map?;
          if (options != null && options.containsKey(filterKey)) {
            final value = options[filterKey];
            matches =
                value == true || (value != null && value.toString().isNotEmpty);
          }
        }

        return matches;
      }).where((inst) => seenAccounts.add(inst['Account'] as String)).toList();

      if (matches.isNotEmpty) {
        final title = filterType == 'Fee Waiver Options'
            ? '$filterKey Waiver'
            : filterKey;
        filtered[title] = matches;
      }
    });
  });

  return filtered;
}

Map<String, List<Map<String, dynamic>>> getFilteredCreditCards(
    List<Map<String, dynamic>> institutions) {
  final Map<String, List<Map<String, dynamic>>> filtered = {};
  final seenAccounts = <String>{};

  creditcardsFilters.forEach((filterType, filters) {
    filters.forEach((filterKey, isEnabled) {
      // For default organization, you may disable this check:
      // if (!isEnabled) return;

      final matches = institutions.where((institution) {
        bool matches = false;

        if (filterType == 'Preferences') {
          final bonus = institution['Bonus Offer'];
          final annualFee = institution['Annual Fee'];
          final apr = institution['Intro Purchases APR'];
          final balanceApr = institution['Intro Balance Transfers APR'];

          switch (filterKey) {
            case 'Bonus Offer':
              matches = bonus != null && bonus != '\$0';
              break;
            case 'No Annual Fee':
              matches = annualFee != null && annualFee.contains('\$0');
              break;
            case '0% APR':
              matches = apr != null && apr.toString().contains('0%');
              break;
            case 'Balance Transfer':
              matches =
                  balanceApr != null && balanceApr.toString().contains('0%');
              break;
          }
        } else if (filterType == 'Program') {
          final program =
              institution['Program']?.toString().toLowerCase() ?? '';
          switch (filterKey) {
            case 'Cash Back':
              matches = program.contains('cash back');
              break;
            case 'Points':
              matches = program.contains('points');
              break;
            case 'Miles':
              matches = program.contains('miles');
              break;
          }
        }

        return matches;
      }).where((inst) => seenAccounts.add(inst['Account'] as String)).toList();

      if (matches.isNotEmpty) {
        final title =
            filterType == 'Program' ? '$filterKey Rewards' : filterKey;
        filtered[title] = matches;
      }
    });
  });

  return filtered;
}

Map<String, List<Map<String, dynamic>>> getFilteredAutoLoans(
    List<Map<String, dynamic>> institutions) {
  final Map<String, List<Map<String, dynamic>>> filtered = {};

  autoloansFilters.forEach((filterType, filters) {
    // Skip the entire "Months Term" category
    if (filterType == 'Months Term') return;

    filters.forEach((filterKey, isEnabled) {
      // if (!isEnabled) return;

      final matches = institutions.where((institution) {
        bool matches = false;

        if (filterType == 'Loan Type') {
          matches = institution['Account'] == filterKey;
        } else if (filterType == 'Seller') {
          matches = institution['Seller'] == filterKey;
        }

        return matches;
      }).toList();

      if (matches.isNotEmpty) {
        String title = filterKey;
        if (filterType == 'Loan Type' &&
            (filterKey == 'New Car' || filterKey == 'Used Car')) {
          title = '$filterKey Loan';
        } else if (filterType == 'Seller' &&
            (filterKey == 'Dealership' || filterKey == 'Private Party')) {
          title = '$filterKey Purchase';
        }

        filtered[title] = matches;
      }
    });
  });

  return filtered;
}

Map<String, List<Map<String, dynamic>>> getFilteredInvestments(
    List<Map<String, dynamic>> institutions) {
  final Map<String, List<Map<String, dynamic>>> filtered = {};

  investmentsFilters.forEach((filterType, filters) {
    filters.forEach((filterKey, isEnabled) {
      final matches = institutions.where((institution) {
        bool matches = false;

        if (filterType == 'Preferences') {
          final commission = institution['Trade Commission'];
          final opening = institution['Min Opening Balance'];

          switch (filterKey) {
            case 'No Commission':
              matches = commission == '\$0';
              break;
            case '\$0 Opening Balance':
              matches = opening == '\$0';
              break;
          }
        } else if (filterType == 'Asset Classes') {
          final value = institution[filterKey];
          matches = value == true;
        }

        return matches;
      }).toList();

      if (matches.isNotEmpty) {
        final title =
            filterType == 'Asset Classes' ? '$filterKey Access' : filterKey;
        filtered[title] = matches;
      }
    });
  });

  return filtered;
}

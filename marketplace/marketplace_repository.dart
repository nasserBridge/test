import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/categories_data.dart';

/// Maps bank name strings (as returned by the scraper) to local logo asset paths.
String _logoForBank(String? bankName) {
  if (bankName == null) return '';
  final lower = bankName.toLowerCase();
  if (lower.contains('bank of america')) {
    return 'assets/logos/bankofamerica.png';
  }
  if (lower.contains('chase') || lower.contains('jp morgan')) {
    return 'assets/logos/chase.png';
  }
  if (lower.contains('wells fargo')) { return 'assets/logos/wellsfargo.png'; }
  if (lower.contains('capital one')) return 'assets/logos/capitalone.png';
  if (lower.contains('citi')) return 'assets/logos/citibank.png';
  if (lower.contains('ally')) return 'assets/logos/allybank.png';
  if (lower.contains('discover')) return 'assets/logos/discover.png';
  if (lower.contains('american express') || lower.contains('amex')) {
    return 'assets/logos/amex.png';
  }
  if (lower.contains('schwab')) return 'assets/logos/charlesschwab.png';
  if (lower.contains('fidelity')) return 'assets/logos/fidelity.png';
  if (lower.contains('vanguard')) return 'assets/logos/vanguard.png';
  if (lower.contains('pnc')) return 'assets/logos/pncbank.png';
  if (lower.contains('merrill')) return 'assets/logos/merrill.png';
  if (lower.contains('usaa')) return 'assets/logos/usaa.png';
  if (lower.contains('rocket')) return 'assets/logos/rocketmortgage.png';
  // No logo available — return empty so the UI can show a placeholder instead
  return '';
}

/// Formats a nullable double as a dollar string, e.g. 4.95 → "\$4.95"
/// Returns "\$0" for null or zero values.
String _formatDollar(dynamic value, {bool zeroAsNull = false}) {
  if (value == null) return zeroAsNull ? '\$0' : '\$0';
  final d = (value as num).toDouble();
  if (d == 0) return '\$0';
  if (d == d.truncateToDouble()) return '\$${d.truncate()}';
  return '\$${d.toStringAsFixed(2)}';
}

/// Formats a nullable double as a dollar string for waiver fields,
/// returning null when the value is absent.
String? _formatDollarOrNull(dynamic value) {
  if (value == null) return null;
  return _formatDollar(value);
}

/// Normalizes an APY/rate string from the scraper into a clean display value.
/// Returns null if no meaningful rate can be extracted, so the UI can skip it.
String? _normalizeRate(dynamic raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty) return null;

  // Already a clean percentage — keep it.
  final cleanPercent = RegExp(r'^\d+(\.\d+)?%$');
  if (cleanPercent.hasMatch(s)) return s;

  // Range like "19.99% - 28.24%" — keep it.
  final rangePercent = RegExp(r'^\d+(\.\d+)?%\s*[-–]\s*\d+(\.\d+)?%$');
  if (rangePercent.hasMatch(s)) return s;

  // Try to extract the first percentage from a longer string.
  final allMatches = RegExp(r'\d+(\.\d+)?%').allMatches(s).toList();
  if (allMatches.length == 1) {
    return allMatches.first.group(0)!;
  }
  if (allMatches.length >= 2) {
    // Return as a range using the lowest and highest values found.
    final values = allMatches
        .map((m) => double.tryParse(m.group(0)!.replaceAll('%', '')) ?? 0)
        .toList()
      ..sort();
    final low = values.first;
    final high = values.last;
    if (low == high) {
      return '${low.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}%';
    }
    return '${low.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}% - ${high.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}%';
  }

  // No percentage found — return null so the card skips this field.
  return null;
}

/// Returns null for empty/whitespace/null strings so the UI can skip them.
String? _cleanString(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty || s == 'null' || s == 'N/A' ? null : s;
}

// ---------------------------------------------------------------------------
// Checking / Savings account mapper
// ---------------------------------------------------------------------------

Map<String, dynamic> _mapBankAccount(Map<String, dynamic> raw) {
  final feeWaiverRaw = raw['Fee_Waiver_Options'] as Map<String, dynamic>?;

  Map<String, dynamic>? feeWaiver;
  if (feeWaiverRaw != null) {
    feeWaiver = {
      'Direct Deposit': _formatDollarOrNull(feeWaiverRaw['Direct_deposit']),
      'Daily Balance':
          _formatDollarOrNull(feeWaiverRaw['Daily_Balance_Amount']),
      'Student': feeWaiverRaw['Student'] ?? false,
      'Transaction Minimum':
          _formatDollarOrNull(feeWaiverRaw['Transaction_Minimum']),
      'Military': feeWaiverRaw['Military'] ?? false,
      'Other': feeWaiverRaw['Other'],
    };
  }

  final atmRaw = raw['ATM_Fees'] as Map<String, dynamic>?;
  Map<String, dynamic>? atmFees;
  if (atmRaw != null) {
    atmFees = {
      'Out-of-Network': atmRaw['Out_of_Network'],
      'International': atmRaw['International'],
    };
  }

  return {
    'URL': raw['URL'] ?? '',
    'Logo': _logoForBank(raw['Bank'] as String?),
    'Bank': raw['Bank'] ?? '',
    'Account': raw['Account'] ?? '',
    if (_normalizeRate(raw['APY']) != null) 'APY': _normalizeRate(raw['APY']),
    'Min Opening Balance': _formatDollar(raw['Min_Opening_Balance']),
    'Bonus Offer': _cleanString(raw['Bonus_Offer']),
    'Monthly Maintenance Fee': _formatDollar(raw['Monthly_Maintenance_Fee']),
    'Fee Waiver Options': feeWaiver,
    'Overdraft Fee': _formatDollar(raw['Overdraft_fee']),
    'ATM Fees': atmFees,
    'Foreign Transaction Fee': _cleanString(raw['Foreign_Transaction_Fee']),
    'Tiered Relationship Program':
        _cleanString(raw['Tiered_relationship_program']),
  };
}

// ---------------------------------------------------------------------------
// Savings account mapper (scraper may use same schema as checking)
// ---------------------------------------------------------------------------

Map<String, dynamic> _mapSavingsAccount(Map<String, dynamic> raw) {
  // Savings accounts share the AccountExtractSchema with checking accounts,
  // but the Fee Waiver schema differs slightly (Age, Linked Account instead
  // of Transaction Minimum). The scraper stores what it finds, so we read
  // both possible key sets gracefully.
  final feeWaiverRaw = raw['Fee_Waiver_Options'] as Map<String, dynamic>?;

  Map<String, dynamic>? feeWaiver;
  if (feeWaiverRaw != null) {
    feeWaiver = {
      'Daily Balance': _formatDollarOrNull(
          feeWaiverRaw['Daily_Balance_Amount'] ??
              feeWaiverRaw['Daily_Balance']),
      'Age': feeWaiverRaw['Age'],
      'Linked Account': feeWaiverRaw['Linked_Account'] ?? false,
      'Military': feeWaiverRaw['Military'] ?? false,
      'Other': feeWaiverRaw['Other'],
    };
  }

  return {
    'URL': raw['URL'] ?? '',
    'Logo': _logoForBank(raw['Bank'] as String?),
    'Bank': raw['Bank'] ?? '',
    'Account': raw['Account'] ?? '',
    if (_normalizeRate(raw['APY']) != null) 'APY': _normalizeRate(raw['APY']),
    'Min Opening Balance': _formatDollar(raw['Min_Opening_Balance']),
    'Bonus Offer': _cleanString(raw['Bonus_Offer']),
    'Monthly Maintenance Fee': _formatDollar(raw['Monthly_Maintenance_Fee']),
    'Fee Waiver Options': feeWaiver,
    'Overdraft Fee': _formatDollar(raw['Overdraft_fee']),
    'Tiered Relationship Program':
        _cleanString(raw['Tiered_relationship_program']),
  };
}

// ---------------------------------------------------------------------------
// Credit card mapper
// ---------------------------------------------------------------------------

Map<String, dynamic> _mapCreditCard(Map<String, dynamic> raw) {
  return {
    'URL': raw['URL'] ?? '',
    'Logo': _logoForBank(raw['Bank'] as String?),
    'Bank': raw['Bank'] ?? '',
    'Account': raw['Account'] ?? '',
    'Bonus Offer': _cleanString(raw['Bonus_Offer']),
    'Annual Fee': _cleanString(raw['Annual_Fee']) ?? '\$0',
    'Intro Purchases APR': _cleanString(raw['Intro_Purchases_APR']),
    'Intro Balance Transfers APR':
        _cleanString(raw['Intro_Balance_Transfers_APR']),
    if (_normalizeRate(raw['Purchases_APR']) != null)
      'Purchases APR': _normalizeRate(raw['Purchases_APR']),
    if (_normalizeRate(raw['Balance_Transfers_APR']) != null)
      'Balance Transfers APR': _normalizeRate(raw['Balance_Transfers_APR']),
    if (_normalizeRate(raw['Cash_Advances_APR']) != null)
      'Cash Advances APR': _normalizeRate(raw['Cash_Advances_APR']),
    'Program': _cleanString(raw['Program']),
    'Foreign Transaction Fee': _cleanString(raw['Foreign_Transaction_Fee']),
    'Rewards': raw['Rewards'] ?? {},
    'Cash Advance Fee': _cleanString(raw['Cash_Advance_Fee']),
    'Balance Transfer Fee': _cleanString(raw['Balance_Transfer_Fee']),
  };
}

// ---------------------------------------------------------------------------
// Investment account mapper
// ---------------------------------------------------------------------------

Map<String, dynamic> _mapInvestment(Map<String, dynamic> raw) {
  final assetClasses = raw['Asset_Classes'];
  return {
    'URL': raw['URL'] ?? '',
    'Logo': _logoForBank(raw['Bank'] as String?),
    'Bank': raw['Bank'] ?? '',
    'Account': raw['Account'] ?? '',
    'Trade Commission': raw['Trade_Commission'] != null
        ? _formatDollar(raw['Trade_Commission'])
        : '\$0',
    'Min Opening Balance': _formatDollar(raw['Min_Opening_Balance']),
    'Asset Classes': assetClasses?.toString() ?? '0',
    'Stocks': raw['Stocks'] ?? false,
    'Bonds': raw['Bonds'] ?? false,
    'Mutual Funds': raw['Mutual_Funds'] ?? false,
    'ETFs': raw['ETFs'] ?? false,
    'Options': raw['Options'] ?? false,
    'CDs': raw['CDs'] ?? false,
    'Crypto': raw['Crypto'] ?? false,
    'Precious Metals': raw['Precious_Metals'] ?? false,
    'International Markets': raw['International_Markets'] ?? false,
    'Money Market Funds': raw['Money_Market_Funds'] ?? false,
    'Fixed Income': raw['Fixed_Income'] ?? false,
    'Index Funds': raw['Index_Funds'] ?? false,
    'Futures': raw['Futures'] ?? false,
    'Forex': raw['Forex'] ?? false,
  };
}

// ---------------------------------------------------------------------------
// Auto Loan mapper
// ---------------------------------------------------------------------------

Map<String, dynamic> _mapLoan(Map<String, dynamic> raw) {
  final terms = raw['Month_Term_Lengths'];
  String? termString;
  if (terms is List && terms.isNotEmpty) {
    final sorted = List<int>.from(terms.whereType<int>())..sort();
    termString = sorted.join(', ');
  }
  return {
    'URL': raw['URL'] ?? '',
    'Logo': _logoForBank(raw['Bank'] as String?),
    'Bank': raw['Bank'] ?? '',
    'Account': raw['Account'] ?? '',
    'Seller': _cleanString(raw['Seller']),
    if (_normalizeRate(raw['APR']) != null) 'APR': _normalizeRate(raw['APR']),
    if (termString != null) 'Month Term Lengths': termString,
    'Prepayment Penalty': raw['Prepayment_Penalty'] ?? false,
  };
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

class MarketplaceRepository {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches all marketplace categories from Firestore and returns them in the
  /// same shape as [getShuffledCategories] from categories_data.dart.
  /// On any error falls back to static data so the UI is never left empty.
  static Future<Map<String, List<Map<String, dynamic>>>>
      fetchCategories() async {
    try {
      final results = await Future.wait([
        _fetchCollection('Checking_accounts'),
        _fetchCollection('Savings_accounts'),
        _fetchCollection('CD_accounts'),
        _fetchCollection('Money_Market_accounts'),
        _fetchCollection('Credit_cards'),
        _fetchCollection('Investment_accounts'),
        _fetchCollection('Loans_accounts'),
      ]);

      final checkings = results[0];
      final savings = results[1];
      final cds = results[2];
      final moneyMarket = results[3];
      final creditCards = results[4];
      final investments = results[5];
      final loans = results[6];

      final allSavings = [
        ...savings.map(_mapSavingsAccount),
        ...cds.map(_mapSavingsAccount),
        ...moneyMarket.map(_mapSavingsAccount),
      ];

      final Map<String, List<Map<String, dynamic>>> categories = {
        if (checkings.isNotEmpty)
          'Checkings': checkings.map(_mapBankAccount).toList(),
        if (allSavings.isNotEmpty)
          'Savings, CDs, & Money Market': allSavings,
        if (creditCards.isNotEmpty)
          'Credit Cards': creditCards.map(_mapCreditCard).toList(),
        if (investments.isNotEmpty)
          'Investments': investments.map(_mapInvestment).toList(),
        if (loans.isNotEmpty) 'Auto Loans': loans.map(_mapLoan).toList(),
      };

      if (categories.isEmpty) return getShuffledCategories();

      final random = Random();
      categories.forEach((_, list) => list.shuffle(random));

      // Fill in any categories missing from Firestore with static fallbacks.
      final staticData = getShuffledCategories();
      for (final key in staticData.keys) {
        categories.putIfAbsent(key, () => staticData[key]!);
      }

      return categories;
    } catch (e) {
      return getShuffledCategories();
    }
  }

  /// Returns the most recent [last_updated] timestamp across all four
  /// Firestore documents, or null if none are available.
  static Future<DateTime?> fetchLastUpdated() async {
    try {
      final docs = await Future.wait([
        _db.collection('Information').doc('Checking_accounts').get(),
        _db.collection('Information').doc('Savings_accounts').get(),
        _db.collection('Information').doc('Credit_cards').get(),
        _db.collection('Information').doc('Investment_accounts').get(),
      ]);

      DateTime? latest;
      for (final doc in docs) {
        if (!doc.exists) continue;
        final ts = doc.data()?['last_updated'];
        if (ts is Timestamp) {
          final dt = ts.toDate();
          if (latest == null || dt.isAfter(latest)) latest = dt;
        }
      }
      return latest;
    } catch (_) {
      return null;
    }
  }

  /// Fetches categories AND the most recent last_updated timestamp in a single
  /// pass so the UI only needs one round trip.
  /// Returns {'categories': Map<...>, 'lastUpdated': DateTime?}
  static Future<Map<String, dynamic>> fetchCategoriesWithMeta() async {
    final results = await Future.wait([
      fetchCategories(),
      fetchLastUpdated(),
    ]);
    return {
      'categories': results[0],
      'lastUpdated': results[1],
    };
  }

  static Future<List<Map<String, dynamic>>> _fetchCollection(
      String documentId) async {
    try {
      final doc = await _db.collection('Information').doc(documentId).get();
      if (!doc.exists) return [];
      final data = doc.data();
      if (data == null) return [];
      final accounts = data['accounts'];
      if (accounts is! List) return [];
      return accounts
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Stream<Map<String, List<Map<String, dynamic>>>> categoriesStream() {
    final docs = [
      'Checking_accounts',
      'Savings_accounts',
      'Credit_cards',
      'Investment_accounts',
      'Loans_accounts',
    ];
    final streams = docs
        .map((id) => _db.collection('Information').doc(id).snapshots())
        .toList();
    return streams[0].asyncMap((_) => fetchCategories()).asBroadcastStream();
  }
}

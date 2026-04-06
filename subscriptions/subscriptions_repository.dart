import 'dart:async';
import 'dart:convert';
import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for a detected or confirmed subscription
class Subscription {
  final String id;
  final String merchantName;
  final double amount;
  final String category;
  final String frequency; // 'monthly', 'weekly', 'yearly', 'custom'
  final DateTime? nextBillingDate;
  final bool isConfirmed; // User has confirmed this is a subscription
  final bool isCustom; // User manually added this
  final List<String>? transactionIds; // Related transaction IDs
  final DateTime lastCharged;

  Subscription({
    required this.id,
    required this.merchantName,
    required this.amount,
    required this.category,
    required this.frequency,
    this.nextBillingDate,
    this.isConfirmed = false,
    this.isCustom = false,
    this.transactionIds,
    required this.lastCharged,
  });

  Subscription copyWith({
    String? id,
    String? merchantName,
    double? amount,
    String? category,
    String? frequency,
    DateTime? nextBillingDate,
    bool? isConfirmed,
    bool? isCustom,
    List<String>? transactionIds,
    DateTime? lastCharged,
  }) {
    return Subscription(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      isCustom: isCustom ?? this.isCustom,
      transactionIds: transactionIds ?? this.transactionIds,
      lastCharged: lastCharged ?? this.lastCharged,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchantName': merchantName,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'isConfirmed': isConfirmed,
      'isCustom': isCustom,
      'transactionIds': transactionIds,
      'lastCharged': lastCharged.toIso8601String(),
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      merchantName: json['merchantName'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] ?? 'Other',
      frequency: json['frequency'] ?? 'Monthly',
      nextBillingDate: json['nextBillingDate'] != null
          ? DateTime.parse(json['nextBillingDate'])
          : null,
      isConfirmed: json['isConfirmed'] ?? false,
      isCustom: json['isCustom'] ?? false,
      transactionIds: json['transactionIds'] != null
          ? List<String>.from(json['transactionIds'])
          : null,
      lastCharged: DateTime.parse(json['lastCharged']),
    );
  }
}

/// Repository for managing subscription detection and data
/// LOCAL VERSION with SharedPreferences persistence
class SubscriptionsRepository extends GetxController {
  static SubscriptionsRepository get instance => Get.find();

  RxList<Subscription> detectedSubscriptions = <Subscription>[].obs;
  RxList<Subscription> confirmedSubscriptions = <Subscription>[].obs;
  RxSet<String> dismissedSubscriptionIds =
      <String>{}.obs; // Track dismissed ones
  RxBool isLoading = true.obs;
  RxBool tryAgain = false.obs;

  static const String _confirmedKey = 'confirmed_subscriptions';
  static const String _customKey = 'custom_subscriptions';
  static const String _dismissedKey = 'dismissed_subscriptions';

  /// Load confirmed, custom, and dismissed subscriptions from SharedPreferences
  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<Subscription> allConfirmed = [];

      // Load confirmed subscriptions
      final confirmedJson = prefs.getString(_confirmedKey);
      if (confirmedJson != null) {
        final List<dynamic> confirmedList = jsonDecode(confirmedJson);
        allConfirmed.addAll(
          confirmedList.map((json) => Subscription.fromJson(json)).toList(),
        );
      }

      // Load custom subscriptions
      final customJson = prefs.getString(_customKey);
      if (customJson != null) {
        final List<dynamic> customList = jsonDecode(customJson);
        allConfirmed.addAll(
          customList.map((json) => Subscription.fromJson(json)).toList(),
        );
      }

      // Deduplicate by normalized merchant name (keep the most recent)
      Map<String, Subscription> deduplicatedMap = {};
      for (var sub in allConfirmed) {
        String normalizedMerchant = _normalizeMerchantName(sub.merchantName);
        // Keep the one with the most recent lastCharged date
        if (!deduplicatedMap.containsKey(normalizedMerchant) ||
            sub.lastCharged
                .isAfter(deduplicatedMap[normalizedMerchant]!.lastCharged)) {
          deduplicatedMap[normalizedMerchant] = sub;
        }
      }

      confirmedSubscriptions.assignAll(deduplicatedMap.values.toList());

      // Load dismissed subscription IDs
      final dismissedJson = prefs.getString(_dismissedKey);
      if (dismissedJson != null) {
        final List<dynamic> dismissedList = jsonDecode(dismissedJson);
        dismissedSubscriptionIds.assignAll(
          dismissedList.map((id) => id.toString()).toSet(),
        );
      }
    } catch (error, stackTrace) {
      LogUtil.error('Error loading persisted subscriptions',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Save confirmed subscriptions to SharedPreferences
  Future<void> _saveConfirmedSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final confirmed = confirmedSubscriptions
          .where((sub) => !sub.isCustom)
          .map((sub) => sub.toJson())
          .toList();
      await prefs.setString(_confirmedKey, jsonEncode(confirmed));
    } catch (error, stackTrace) {
      LogUtil.error('Error saving confirmed subscriptions',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Save custom subscriptions to SharedPreferences
  Future<void> _saveCustomSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final custom = confirmedSubscriptions
          .where((sub) => sub.isCustom)
          .map((sub) => sub.toJson())
          .toList();
      await prefs.setString(_customKey, jsonEncode(custom));
    } catch (error, stackTrace) {
      LogUtil.error('Error saving custom subscriptions',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Save dismissed subscription IDs to SharedPreferences
  Future<void> _saveDismissedSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _dismissedKey, jsonEncode(dismissedSubscriptionIds.toList()));
    } catch (error, stackTrace) {
      LogUtil.error('Error saving dismissed subscriptions',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Initialize and fetch subscription data
  Future<void> initialize(List<Map<String, dynamic>> allTransactions) async {
    isLoading.value = true;
    tryAgain.value = false;

    try {

      if (allTransactions.isEmpty) {
        isLoading.value = false;
        return;
      }

      // CRITICAL: Load persisted data FIRST before detecting
      await _loadPersistedData();


      // Now detect potential subscriptions (will skip confirmed/dismissed)
      _detectSubscriptions(allTransactions);

      isLoading.value = false;

    } catch (error, stackTrace) {
      tryAgain.value = true;
      isLoading.value = false;
      LogUtil.error('Error initializing subscriptions',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Auto-detect recurring transactions that might be subscriptions
  void _detectSubscriptions(List<Map<String, dynamic>> transactions) {
    try {

      // Filter transactions based on account type
      List<Map<String, dynamic>> relevantTransactions = [];

      for (var transaction in transactions) {
        String accountGroup = transaction['AccountGroup'] ?? '';
        double amount = _parseAmount(transaction['Amount']);

        // For depository accounts (Checking, Savings): only include outflows (negative amounts)
        if (accountGroup == 'Checkings' || accountGroup == 'Savings') {
          if (amount < 0) {
            relevantTransactions.add(transaction);
          }
        }
        // For credit/liability accounts (Credit Cards, Loans): only include charges (positive amounts)
        else if (accountGroup == 'Credit Cards' || accountGroup == 'Loans') {
          if (amount > 0) {
            relevantTransactions.add(transaction);
          }
        }
        // For other account types, include all
        else {
          relevantTransactions.add(transaction);
        }
      }


      // Group transactions by merchant name
      Map<String, List<Map<String, dynamic>>> merchantGroups = {};

      for (var transaction in relevantTransactions) {
        String merchant = transaction['Transaction'] ?? '';
        if (merchant.isEmpty) continue;

        // Normalize merchant name (remove numbers, special chars for better grouping)
        String normalizedMerchant = _normalizeMerchantName(merchant);

        if (!merchantGroups.containsKey(normalizedMerchant)) {
          merchantGroups[normalizedMerchant] = [];
        }
        merchantGroups[normalizedMerchant]!.add(transaction);
      }


      List<Subscription> detected = [];

      // Analyze each merchant group for recurring patterns
      merchantGroups.forEach((merchant, merchantTransactions) {

        if (merchantTransactions.length >= 3) {
          // Need at least 2 transactions to detect pattern
          final pattern = _analyzeRecurringPattern(merchantTransactions);

          if (pattern != null) {
            // Create consistent ID based on normalized merchant name
            final normalizedMerchant =
                _normalizeMerchantName(pattern.merchantName);
            final consistentId = 'sub_$normalizedMerchant';
            final patternWithId = Subscription(
              id: consistentId,
              merchantName: pattern.merchantName,
              amount: pattern.amount,
              category: pattern.category,
              frequency: pattern.frequency,
              nextBillingDate: pattern.nextBillingDate,
              isConfirmed: false,
              isCustom: false,
              transactionIds: pattern.transactionIds,
              lastCharged: pattern.lastCharged,
            );


            // Check if already confirmed (by normalized merchant name)
            bool alreadyConfirmed = confirmedSubscriptions.any((sub) {
              String confirmedNormalized =
                  _normalizeMerchantName(sub.merchantName);
              return confirmedNormalized == normalizedMerchant;
            });

            // Check if dismissed
            bool isDismissed = dismissedSubscriptionIds.contains(consistentId);

            if (alreadyConfirmed) {
            } else if (isDismissed) {
            } else {
              detected.add(patternWithId);
            }
          }
        }
      });

      detectedSubscriptions.assignAll(detected);
    } catch (error, stackTrace) {
      LogUtil.error('Error detecting subscriptions',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Normalize merchant name for better grouping
  String _normalizeMerchantName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\b(inc|llc|corp|ltd)\b'), '')
        .trim();
  }

  /// Analyze transactions to detect recurring pattern
  Subscription? _analyzeRecurringPattern(
      List<Map<String, dynamic>> transactions) {
    try {
      // Sort by date
      transactions.sort((a, b) {
        DateTime dateA = _parseDate(a['Date']);
        DateTime dateB = _parseDate(b['Date']);
        return dateA.compareTo(dateB);
      });

      // Calculate weighted average amount and check variance
      // Use weighted average to handle varying amounts (like gym fees with occasional price changes)
      List<double> amounts =
          transactions.map((t) => _parseAmount(t['Amount']).abs()).toList();

      // Calculate average and standard deviation
      double avgAmount = amounts.reduce((a, b) => a + b) / amounts.length;

      // Check if amounts are within acceptable range
      // Allow up to 20% variance OR $5 absolute difference (whichever is larger)
      double maxVariance = avgAmount * 0.30; // 30% of average
      if (maxVariance < 5.0) maxVariance = 7.0; // At least $7 tolerance

      bool similarAmounts = amounts.every((amount) {
        return (amount - avgAmount).abs() <= maxVariance;
      });


      if (!similarAmounts) return null;

      // Calculate average interval between transactions
      List<int> intervals = [];
      for (int i = 1; i < transactions.length; i++) {
        DateTime date1 = _parseDate(transactions[i - 1]['Date']);
        DateTime date2 = _parseDate(transactions[i]['Date']);
        int daysDiff = date2.difference(date1).inDays;
        intervals.add(daysDiff);
      }

      if (intervals.isEmpty) return null;

      double avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;


      // Determine frequency based on average interval
      String frequency;
      if (avgInterval >= 25 && avgInterval <= 40) {
        frequency = 'Monthly';
      } else if (avgInterval >= 6 && avgInterval <= 10) {
        frequency = 'Weekly';
      } else if (avgInterval >= 75 && avgInterval <= 115) {
        frequency = 'Quarterly';
      } else if (avgInterval >= 330 && avgInterval <= 420) {
        frequency = 'Yearly';
      } else {
        return null;
      }

      // Get the most recent transaction
      final latestTransaction = transactions.last;
      DateTime lastDate = _parseDate(latestTransaction['Date']);

      // Calculate next billing date
      DateTime nextBilling;
      switch (frequency) {
        case 'Monthly':
          nextBilling = DateTime(
            lastDate.year,
            lastDate.month + 1,
            1,
          ).add(Duration(days: lastDate.day - 1));
          break;
        case 'Weekly':
          nextBilling = lastDate.add(Duration(days: 7));
          break;
        case 'Quarterly':
          nextBilling =
              DateTime(lastDate.year, lastDate.month + 3, lastDate.day);
          break;
        case 'Yearly':
          nextBilling =
              DateTime(lastDate.year + 1, lastDate.month, lastDate.day);
          break;
        default:
          nextBilling = lastDate.add(Duration(days: avgInterval.round()));
      }

      // Categorize the subscription
      String category =
          _categorizeSubscription(latestTransaction['Transaction']);

      return Subscription(
        id: 'detected_${DateTime.now().millisecondsSinceEpoch}',
        merchantName: latestTransaction['Transaction'],
        amount: avgAmount, // Use weighted average instead of first amount
        category: category,
        frequency: frequency,
        nextBillingDate: nextBilling,
        isConfirmed: false,
        isCustom: false,
        transactionIds: transactions
            .map((t) => '${t['Transaction']}_${t['Date']}')
            .toList(),
        lastCharged: lastDate,
      );
    } catch (error) {
      return null;
    }
  }

  /// Parse date from various formats
  DateTime _parseDate(String dateStr) {
    try {
      // Try MM/DD/YYYY format
      if (dateStr.contains('/')) {
        List<String> parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[0]), // month
            int.parse(parts[1]), // day
          );
        }
      }

      // Try YYYY-MM-DD format
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Parse dollar amount from formatted string
  double _parseAmount(dynamic amountValue) {
    try {
      // If it's already a number
      if (amountValue is num) {
        return amountValue.toDouble();
      }

      // If it's a string, clean it
      String amountStr = amountValue.toString();
      String cleaned =
          amountStr.replaceAll('\$', '').replaceAll(',', '').trim();
      return double.tryParse(cleaned) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Categorize subscription based on merchant name
  String _categorizeSubscription(String merchantName) {
    String lower = merchantName.toLowerCase();

    if (lower.contains('netflix') ||
        lower.contains('hulu') ||
        lower.contains('spotify') ||
        lower.contains('apple music') ||
        lower.contains('youtube') ||
        lower.contains('disney') ||
        lower.contains('hbo') ||
        lower.contains('prime video')) {
      return 'Entertainment';
    } else if (lower.contains('gym') ||
        lower.contains('fitness') ||
        lower.contains('yoga') ||
        lower.contains('planet fitness') ||
        lower.contains('crunch')) {
      return 'Health & Fitness';
    } else if (lower.contains('adobe') ||
        lower.contains('microsoft') ||
        lower.contains('google') ||
        lower.contains('dropbox') ||
        lower.contains('github') ||
        lower.contains('aws') ||
        lower.contains('zoom')) {
      return 'Software & Apps';
    } else if (lower.contains('phone') ||
        lower.contains('verizon') ||
        lower.contains('at&t') ||
        lower.contains('t-mobile') ||
        lower.contains('internet') ||
        lower.contains('comcast') ||
        lower.contains('spectrum')) {
      return 'Utilities';
    } else if (lower.contains('insurance') ||
        lower.contains('geico') ||
        lower.contains('state farm') ||
        lower.contains('progressive')) {
      return 'Insurance';
    } else if (lower.contains('news') ||
        lower.contains('magazine') ||
        lower.contains('times') ||
        lower.contains('journal')) {
      return 'News & Media';
    } else {
      return 'Other';
    }
  }

  /// Confirm a detected subscription and save to SharedPreferences
  Future<void> confirmSubscription(Subscription subscription) async {
    try {
      // Check if this subscription is already confirmed (by normalized merchant name)
      String normalizedMerchant =
          _normalizeMerchantName(subscription.merchantName);
      bool alreadyExists = confirmedSubscriptions.any((sub) {
        return _normalizeMerchantName(sub.merchantName) == normalizedMerchant;
      });

      if (alreadyExists) {
        // Just remove from detected list
        detectedSubscriptions.removeWhere((s) => s.id == subscription.id);
        return;
      }

      // Mark as confirmed
      final confirmedSub = subscription.copyWith(isConfirmed: true);

      // Add to confirmed list
      confirmedSubscriptions.add(confirmedSub);

      // Remove from detected list
      detectedSubscriptions.removeWhere((s) => s.id == subscription.id);

      // Save to SharedPreferences
      await _saveConfirmedSubscriptions();

    } catch (error, stackTrace) {
      LogUtil.error('Error confirming subscription',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Add a custom subscription and save to SharedPreferences
  Future<void> addCustomSubscription(
    String name,
    double amount,
    String category,
    String frequency,
    DateTime nextBillingDate,
  ) async {
    try {
      String id = 'custom_${DateTime.now().millisecondsSinceEpoch}';

      final subscription = Subscription(
        id: id,
        merchantName: name,
        amount: amount,
        category: category,
        frequency: frequency,
        nextBillingDate: nextBillingDate,
        isConfirmed: true,
        isCustom: true,
        lastCharged: DateTime.now(),
      );

      confirmedSubscriptions.add(subscription);

      // Save to SharedPreferences
      await _saveCustomSubscriptions();

    } catch (error, stackTrace) {
      LogUtil.error('Error adding custom subscription',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Delete a subscription and save to SharedPreferences
  /// This will remove ALL instances of the same merchant (in case of duplicates)
  Future<void> deleteSubscription(Subscription subscription) async {
    try {
      // Normalize merchant name to catch duplicates
      String normalizedMerchant =
          _normalizeMerchantName(subscription.merchantName);

      // Remove ALL subscriptions with the same normalized merchant name
      int removedCount = confirmedSubscriptions.length;
      confirmedSubscriptions.removeWhere((s) {
        return _normalizeMerchantName(s.merchantName) == normalizedMerchant;
      });
      removedCount = removedCount - confirmedSubscriptions.length;

      // Save to SharedPreferences
      if (subscription.isCustom) {
        await _saveCustomSubscriptions();
      } else {
        await _saveConfirmedSubscriptions();
      }

    } catch (error, stackTrace) {
      LogUtil.error('Error deleting subscription',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Dismiss a detected subscription (save to prevent showing again)
  Future<void> dismissDetectedSubscription(Subscription subscription) async {
    try {
      // Add to dismissed set
      dismissedSubscriptionIds.add(subscription.id);

      // Remove from detected list
      detectedSubscriptions.removeWhere((s) => s.id == subscription.id);

      // Save dismissed IDs
      await _saveDismissedSubscriptions();

    } catch (error, stackTrace) {
      LogUtil.error('Error dismissing subscription',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Retry loading data
  Future<void> retryData(List<Map<String, dynamic>> allTransactions) async {
    isLoading.value = true;
    tryAgain.value = false;
    await initialize(allTransactions);
  }

  /// Calculate total monthly cost of all confirmed subscriptions
  double getTotalMonthlyCost() {
    double total = 0.0;

    for (var sub in confirmedSubscriptions) {
      switch (sub.frequency) {
        case 'Weekly':
          total += sub.amount * 4.33; // Average weeks per month
          break;
        case 'Monthly':
          total += sub.amount;
          break;
        case 'Quarterly':
          total += sub.amount / 3;
          break;
        case 'Yearly':
          total += sub.amount / 12;
          break;
      }
    }

    return total;
  }

  /// Reset all subscription data (confirmed, custom, dismissed)
  Future<void> resetAllData() async {
    try {

      final prefs = await SharedPreferences.getInstance();

      // Clear from SharedPreferences
      await prefs.remove(_confirmedKey);
      await prefs.remove(_customKey);
      await prefs.remove(_dismissedKey);

      // Clear in-memory data
      confirmedSubscriptions.clear();
      detectedSubscriptions.clear();
      dismissedSubscriptionIds.clear();

    } catch (error, stackTrace) {
      LogUtil.error('Error resetting subscription data',
          error: error, stackTrace: stackTrace);
    }
  }

  void manuallyDispose() {
    if (Get.isRegistered<SubscriptionsRepository>()) {
      Get.delete<SubscriptionsRepository>();
    }
  }
}

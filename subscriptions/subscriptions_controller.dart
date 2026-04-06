import 'dart:async';
import 'package:get/get.dart';
import 'subscriptions_repository.dart';
import 'aggregated_transactions_controller.dart';

class SubscriptionsController extends GetxController {
  late final SubscriptionsRepository _repository;

  // Worker to watch for transaction changes
  Worker? _transactionWatcher;

  // Debounce timer to prevent excessive scans
  Timer? _scanDebounceTimer;

  // Track last scan to prevent duplicates
  DateTime? _lastScanTime;
  int _lastTransactionCount = 0;

  // Minimum time between scans (in seconds)
  static const int _minScanIntervalSeconds = 30;

  // Debounce delay (in milliseconds)
  static const int _debounceDelayMs = 2000;

  SubscriptionsController();

  // Proxy to repository observables
  RxList<Subscription> get detectedSubscriptions =>
      _repository.detectedSubscriptions;
  RxList<Subscription> get confirmedSubscriptions =>
      _repository.confirmedSubscriptions;
  RxBool get isLoading => _repository.isLoading;
  RxBool get tryAgain => _repository.tryAgain;

  @override
  void onInit() {
    super.onInit();
    _repository = Get.put(SubscriptionsRepository());

    // Watch for transaction changes with smart debouncing
    if (Get.isRegistered<AggregatedTransactionsController>()) {
      final aggController = Get.find<AggregatedTransactionsController>();

      // TRIGGER 1: Initial scan on app launch
      _debouncedScan(aggController.allTransactions.toList(), force: true);

      // TRIGGER 2 & 3: Watch for new transactions or account links
      _transactionWatcher = ever(aggController.allTransactions, (transactions) {
        _handleTransactionUpdate(transactions);
      });
    } else {
      // No transactions controller found, initialize with empty list
      _initializeAsync([]);
    }
  }

  /// Handle transaction updates with smart filtering
  void _handleTransactionUpdate(List<Map<String, dynamic>> transactions) {
    final currentCount = transactions.length;

    // Only scan if transaction count actually changed
    if (currentCount == _lastTransactionCount) {
      return;
    }

    final countDifference = (currentCount - _lastTransactionCount).abs();

    // Determine if this is a significant update
    bool isSignificantUpdate = false;

    if (_lastTransactionCount == 0 && currentCount > 0) {
      // Initial data load
      isSignificantUpdate = true;
    } else if (countDifference >= 5) {
      // Significant batch of new transactions (new account linked or Plaid sync)
      isSignificantUpdate = true;
    } else if (countDifference > 0) {
      // Small update (few new transactions)
      isSignificantUpdate = false; // Will be debounced
    }

    _lastTransactionCount = currentCount;

    // Scan with debouncing (unless it's a significant update)
    _debouncedScan(transactions, force: isSignificantUpdate);
  }

  /// Debounced scan to prevent excessive rescanning
  void _debouncedScan(List<Map<String, dynamic>> transactions,
      {bool force = false}) {
    // Cancel any pending scan
    _scanDebounceTimer?.cancel();

    // Check if we should skip based on recency
    if (!force && _lastScanTime != null) {
      final secondsSinceLastScan =
          DateTime.now().difference(_lastScanTime!).inSeconds;

      if (secondsSinceLastScan < _minScanIntervalSeconds) {
        // Schedule a delayed scan instead
        _scanDebounceTimer =
            Timer(Duration(milliseconds: _debounceDelayMs), () {
          _executeScan(transactions);
        });
        return;
      }
    }

    // For forced scans or first scan, execute immediately
    if (force) {
      _executeScan(transactions);
    } else {
      // For normal updates, debounce
      _scanDebounceTimer = Timer(Duration(milliseconds: _debounceDelayMs), () {
        _executeScan(transactions);
      });
    }
  }

  /// Execute the actual scan
  void _executeScan(List<Map<String, dynamic>> transactions) {
    _lastScanTime = DateTime.now();
    _initializeAsync(transactions);
  }

  /// TRIGGER 4: Manual rescan triggered by user
  Future<void> manualRescan() async {
    if (Get.isRegistered<AggregatedTransactionsController>()) {
      final aggController = Get.find<AggregatedTransactionsController>();

      // Cancel any pending debounced scans
      _scanDebounceTimer?.cancel();

      // Force immediate scan
      _lastScanTime = DateTime.now();
      await _initializeAsync(aggController.allTransactions.toList());
    } else {
      await _initializeAsync([]);
    }
  }

  /// TRIGGER 5: Scan after Plaid sync completes (called from external controller)
  Future<void> scanAfterPlaidSync() async {
    if (Get.isRegistered<AggregatedTransactionsController>()) {
      final aggController = Get.find<AggregatedTransactionsController>();

      // Wait a moment for transactions to settle
      await Future.delayed(Duration(milliseconds: 500));

      // Force immediate scan
      _lastScanTime = DateTime.now();
      await _initializeAsync(aggController.allTransactions.toList());
    }
  }

  /// Initialize subscriptions asynchronously
  Future<void> _initializeAsync(List<Map<String, dynamic>> transactions) async {
    await _repository.initialize(transactions);
  }

  @override
  void onClose() {
    _scanDebounceTimer?.cancel();
    _transactionWatcher?.dispose();
    _repository.onClose();
    super.onClose();
  }

  /// Confirm a detected subscription
  Future<void> confirmSubscription(Subscription subscription) async {
    await _repository.confirmSubscription(subscription);
  }

  /// Dismiss a detected subscription
  Future<void> dismissDetectedSubscription(Subscription subscription) async {
    await _repository.dismissDetectedSubscription(subscription);
  }

  /// Add a custom subscription
  Future<void> addCustomSubscription(
    String name,
    double amount,
    String category,
    String frequency,
    DateTime nextBillingDate,
  ) async {
    await _repository.addCustomSubscription(
      name,
      amount,
      category,
      frequency,
      nextBillingDate,
    );
  }

  /// Delete a subscription
  Future<void> deleteSubscription(Subscription subscription) async {
    await _repository.deleteSubscription(subscription);
  }

  /// Get total monthly cost
  double getTotalMonthlyCost() {
    return _repository.getTotalMonthlyCost();
  }

  /// Retry loading data (used by error state)
  Future<void> retryData() async {
    await manualRescan();
  }

  /// Reset all subscription data and rescan from scratch
  Future<void> resetAllData() async {
    // Clear all data in repository
    await _repository.resetAllData();

    // Trigger a fresh scan
    await manualRescan();
  }

  void manuallyDispose() {
    _scanDebounceTimer?.cancel();
    _repository.manuallyDispose();
    if (Get.isRegistered<SubscriptionsController>()) {
      Get.delete<SubscriptionsController>();
    }
  }
}

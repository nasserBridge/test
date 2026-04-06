import 'dart:async';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';
import 'package:bridgeapp/src/exceptions/exception_logging.dart';
import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/link_tokens/consents_link_token_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_repository.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_service.dart';
import 'package:bridgeapp/src/repository/authentication_repository/authentication_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bridgeapp/src/utils/decryptor.dart';
import 'package:get/get.dart';

class HoldingsController extends GetxController {
  final AccountModel accountData;

  HoldingsController({required this.accountData});

  final String? userUID =
      AuthenticationRepository.instance.firebaseUser.value?.uid;

  // Observables - CHANGED to List
  var isLoading = true.obs;
  var tryAgain = false.obs;
  var bankSupported = true.obs;
  Rx<List<HoldingsModel>?> holdingsData = Rx<List<HoldingsModel>?>(null);

  // Firebase subscription
  StreamSubscription<DatabaseEvent>? _dbRefSubscription;

  // Initialize the HoldingsService
  late HoldingsService _serviceHoldings;

  @override
  void onInit() {
    super.onInit();
    _serviceHoldings = HoldingsService();
    String tag = 'accountLevel';
    if (Get.isRegistered<ConsentsLinkTokenController>(tag: tag)) {
      _consentController = Get.find<ConsentsLinkTokenController>(tag: tag);
    } else {
      _consentController = Get.put(
        ConsentsLinkTokenController(tag: tag),
        tag: tag,
      );
    }

    _dbListener(accountData.accountId);
  }

  @override
  void onClose() {
    _consentWorker?.dispose();
    manuallyDispose();
    super.onClose();
  }

  /// Request holdings data from Firebase
  Future<void> _dbListener(String accountID) async {
    isLoading.value = true;
    tryAgain.value = false;
    final repo = HoldingsRepo(accountID: accountID);

    _dbRefSubscription = repo.dbStream().listen((DatabaseEvent event) {
      try {
        final data = Decryptor().anyData(event.snapshot.value);

        if (data == null) {
          holdingsData.value = null;
        } else {
          // Parse data into list of holdings
          holdingsData.value = _parseHoldingsData(data);
        }
        isLoading.value = false;
      } catch (error, stackTrace) {
        isLoading.value = false;
        tryAgain.value = true;
        LogUtil.error('Error handling Investments Data',
            error: error, stackTrace: stackTrace);
      }
    }, onError: (error) {
      isLoading.value = false;
      tryAgain.value = true;
      LogUtil.warning(error);
    });
  }

  /// Parse holdings data from the known backend structure
  /// Data structure: { balance: {...}, initialized: "True", holdings: { securityId: {...}, ... } }
  /// Without it, app would crash because the UI would receive a nested Map instead of a List of models.
  /// It's essentially a data adapter that transforms backend format → app format.The function transforms the nested Map structure into a flat List.
  List<HoldingsModel> _parseHoldingsData(dynamic data) {
    try {
      // Data is a Map with a 'holdings' key
      if (data is Map && data.containsKey('holdings')) {
        final holdingsData = data['holdings'];

        // Holdings is a Map where keys are security IDs and values are holding objects
        if (holdingsData is Map) {
          return holdingsData.values
              .map((item) => _serviceHoldings.toModel(item))
              .toList();
        }
      }

      // If structure is unexpected, return empty list
      LogUtil.warning(
          'Unexpected holdings data structure: ${data.runtimeType}');
      return [];
    } catch (error, stackTrace) {
      LogUtil.error('Error parsing holdings data',
          error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// Retry data request
  Future<void> retryData(String type) async {
    final accountID = accountData.accountId;
    isLoading.value = true;
    tryAgain.value = false;

    _disposeSubscription();
    await _dbListener(accountID);
  }

  /// Refresh data
  Future<void> refreshData() async {
    final accountID = accountData.accountId;

    _disposeSubscription();
    await _dbListener(accountID);
  }

  /// Dispose Firebase subscription
  void _disposeSubscription() {
    _dbRefSubscription?.cancel();
    _dbRefSubscription = null;
  }

  /// Manual dispose for widget disposal
  void manuallyDispose() {
    _disposeSubscription();
  }

  late ConsentsLinkTokenController _consentController;
  Worker? _consentWorker;
  bool _consentLinkToken = false;

  void setupConsentListener() {
    _consentWorker =
        ever<bool>(_consentController.consentsLinkTokenBool, (value) {
      if (value == false && _consentLinkToken == true) {
        // Refresh data when consent process is complete
        _serviceHoldings.plaidRequest(accountData.accountId, false);
        SnackbarService.show(
          'Update consents to view latest Holdings data.',
          isError: false,
        );
      }
      _consentLinkToken = value;
    });
  }
}

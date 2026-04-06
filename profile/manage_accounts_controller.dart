import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/accounts_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/repositories/remove_account_repository.dart';
import 'package:get/get.dart';
import 'package:bridgeapp/src/features/authentication/models/linked_account_model.dart';
import 'package:bridgeapp/src/common_widgets/snackbar_service.dart';

class ManageAccountsController extends GetxController {
  late final RemoveAccountRepo _removeRepo;
  late final AccountsController _accountsController;

  /// UI-ready linked accounts
  final RxList<LinkedAccount> accounts = <LinkedAccount>[].obs;

  /// Accounts grouped by institution
  final RxMap<String, List<LinkedAccount>> accountsByInstitution =
      <String, List<LinkedAccount>>{}.obs;

  /// Selected account IDs
  final RxSet<String> selectedAccountIds = <String>{}.obs;

  /// Loading state for deletion
  final RxBool isDeleting = false.obs;

  /// Worker subscription for allBalanceData changes
  Worker? _balanceDataWorker;

  @override
  void onInit() {
    super.onInit();

    _removeRepo = Get.find<RemoveAccountRepo>();
    _accountsController = Get.find<AccountsController>();

    _loadAccounts();

    // React to any changes in allBalanceData
    _balanceDataWorker =
        ever(_accountsController.allBalanceData, (_) => _loadAccounts());
  }

  @override
  void onClose() {
    _balanceDataWorker?.dispose();
    super.onClose();
  }

  /// Load and map accounts from [AccountsController.allBalanceData]
  void _loadAccounts() {
    try {
      final data = _accountsController.allBalanceData;

      if (data.isEmpty) {
        accounts.clear();
        accountsByInstitution.clear();
        return;
      }

      final loadedAccounts = data.entries.map((entry) {
        final model = entry.value;

        // Use available balance when present, otherwise fall back to current.
        // For credit/loan accounts the meaningful balance is current.
        final double rawBalance = model.balances.available != 0
            ? model.balances.available
            : model.balances.current;

        final String formattedBalance =
            '\$${rawBalance.abs().toStringAsFixed(2)}';

        return LinkedAccount(
          accountId: model.accountId,
          name: model.accountName,
          institution: model.institution,
          type: model.type, // e.g. "depository", "credit"
          subtype: model.subtype, // e.g. "checking", "savings"
          mask: model.mask,
          balance: formattedBalance,
        );
      }).toList();

      accounts.assignAll(loadedAccounts);
      _groupAccountsByInstitution(loadedAccounts);
    } catch (e) {
      SnackbarService.show('Failed to load accounts', isError: true);
    }
  }

  /// Group accounts by institution for organised display
  void _groupAccountsByInstitution(List<LinkedAccount> allAccounts) {
    final Map<String, List<LinkedAccount>> grouped = {};

    for (final account in allAccounts) {
      grouped.putIfAbsent(account.institution, () => []).add(account);
    }

    accountsByInstitution.assignAll(grouped);
  }

  /// Toggle selection for an account
  void toggleSelection(String accountId) {
    if (selectedAccountIds.contains(accountId)) {
      selectedAccountIds.remove(accountId);
    } else {
      selectedAccountIds.add(accountId);
    }
  }

  /// Clear all selections
  void clearSelection() {
    selectedAccountIds.clear();
  }

  /// Remove selected accounts
  Future<void> removeSelectedAccounts() async {
    if (selectedAccountIds.isEmpty) return;

    isDeleting.value = true;

    final failedDeletes = <String>[];
    final successfulDeletes = <String>[];

    for (final id in List<String>.from(selectedAccountIds)) {
      try {
        _removeRepo.removeaccount(id);
        successfulDeletes.add(id);
      } catch (e) {
        failedDeletes.add(id);
      }
    }

    isDeleting.value = false;

    // Remove successfully deleted accounts from the local list immediately;
    // the DB listener in AccountsController will also fire and reconcile.
    accounts.removeWhere(
      (account) => successfulDeletes.contains(account.accountId),
    );

    selectedAccountIds.clear();
    selectedAccountIds.addAll(failedDeletes);

    if (failedDeletes.isEmpty) {
      final count = successfulDeletes.length;
      SnackbarService.show(
        '$count account${count > 1 ? 's' : ''} removed successfully',
      );
      // Trigger a balance refresh so the rest of the app reflects the change
      _accountsController.updateExistingAccounts(null);
    } else if (successfulDeletes.isEmpty) {
      SnackbarService.show(
        'Failed to remove accounts. Please try again.',
        isError: true,
      );
    } else {
      SnackbarService.show(
        '${successfulDeletes.length} account${successfulDeletes.length > 1 ? 's' : ''} removed. '
        '${failedDeletes.length} failed.',
        isError: true,
      );
      _accountsController.updateExistingAccounts(null);
    }
  }

  /// Manually refresh the accounts list
  @override
  void refresh() {
    _loadAccounts();
  }
}

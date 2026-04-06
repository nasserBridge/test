import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/screens/profile/accounts_tile.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'manage_accounts_controller.dart';

class ManageAccountsPage extends StatelessWidget {
  const ManageAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManageAccountsController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Manage Accounts',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: Scale.x(16),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.accounts.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Header with selection info
            _buildHeader(controller),

            // Accounts list - GROUPED BY INSTITUTION
            Expanded(
              child: Obx(() {
                if (controller.accountsByInstitution.isEmpty) {
                  return const SizedBox.shrink();
                }

                return ListView.builder(
                  padding: EdgeInsets.all(Scale.x(16)),
                  itemCount: controller.accountsByInstitution.length,
                  itemBuilder: (context, index) {
                    final institution =
                        controller.accountsByInstitution.keys.elementAt(index);
                    final institutionAccounts =
                        controller.accountsByInstitution[institution]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Institution header
                        Padding(
                          padding: EdgeInsets.only(
                              left: Scale.x(4),
                              bottom: Scale.x(12),
                              top: index == 0 ? 0 : Scale.x(16)),
                          child: Text(
                            institution,
                            style: TextStyle(
                              fontSize: FontSizes.accountGroup,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                        ),

                        // Accounts for this institution
                        ...institutionAccounts.map((account) {
                          return Obx(() {
                            final isSelected = controller.selectedAccountIds
                                .contains(account.accountId);

                            return Padding(
                              padding: EdgeInsets.only(bottom: Scale.x(12)),
                              child: AccountTile(
                                account: account,
                                isSelected: isSelected,
                                onTap: () => controller
                                    .toggleSelection(account.accountId),
                              ),
                            );
                          });
                        }),
                      ],
                    );
                  },
                );
              }),
            ),

            // Delete button
            _buildDeleteButton(controller, context),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(ManageAccountsController controller) {
    return Obx(() {
      final selectedCount = controller.selectedAccountIds.length;
      final totalCount = controller.accounts.length;

      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: Scale.x(16), vertical: Scale.x(12)),
        decoration: BoxDecoration(
          color: AppColors.navy.withValues(alpha: 0.05),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedCount > 0
                    ? '$selectedCount of $totalCount selected'
                    : 'Select accounts to remove',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: FontSizes.statements,
                  fontWeight:
                      selectedCount > 0 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selectedCount > 0)
              TextButton(
                onPressed: controller.clearSelection,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: FontSizes.statements,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDeleteButton(
      ManageAccountsController controller, BuildContext context) {
    return Obx(() {
      final hasSelection = controller.selectedAccountIds.isNotEmpty;
      final isDeleting = controller.isDeleting.value;

      return Container(
        padding: EdgeInsets.all(Scale.x(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, Scale.x(-2)),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: Scale.x(50),
            child: ElevatedButton(
              onPressed: hasSelection && !isDeleting
                  ? () => _showDeleteConfirmation(controller, context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    hasSelection ? Colors.red.shade600 : Colors.grey.shade300,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Scale.x(12)),
                ),
                elevation: 0,
              ),
              child: isDeleting
                  ? SizedBox(
                      height: Scale.x(20),
                      width: Scale.x(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      hasSelection
                          ? 'Remove ${controller.selectedAccountIds.length} Account${controller.selectedAccountIds.length > 1 ? 's' : ''}'
                          : 'Select accounts to remove',
                      style: TextStyle(
                        color:
                            hasSelection ? Colors.white : Colors.grey.shade600,
                        fontSize: FontSizes.statements,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Scale.x(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: Scale.x(24)),
            Text(
              'No Accounts Found',
              style: TextStyle(
                fontSize: FontSizes.statements,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: Scale.x(8)),
            Text(
              'You don\'t have any linked accounts to manage.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: FontSizes.statements,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      ManageAccountsController controller, BuildContext context) {
    final count = controller.selectedAccountIds.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Scale.x(16)),
        ),
        title: const Text(
          'Remove Accounts?',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          count > 1
              ? 'Are you sure you want to remove $count accounts? This action cannot be undone.'
              : 'Are you sure you want to remove this account? This action cannot be undone.',
          style: TextStyle(
            fontSize: FontSizes.statements,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: FontSizes.statements,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              controller.removeSelectedAccounts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Scale.x(8)),
              ),
              elevation: 0,
            ),
            child: Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontSize: FontSizes.statements,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/deposit_account_transactions/deposit_single_transaction.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/try_again.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/repositories/transactions_repository.dart';
import 'package:get/get.dart';

class DepositRecentTransactionList extends StatefulWidget {
  final AccountModel account;

  const DepositRecentTransactionList({super.key, required this.account});

  @override
  State<DepositRecentTransactionList> createState() =>
      _DepositRecentTransactionListState();
}

class _DepositRecentTransactionListState
    extends State<DepositRecentTransactionList> {
  /// Instantiate the Transactions Repository
  final _repoTransactions = Get.put(TransactionsRepository());
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _repoTransactions.fetchTransactionData(widget.account, false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _repoTransactions.manuallyDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WhiteContainer(
      padding: EdgeInsets.only(
          left: Scale.x(10), right: Scale.x(10), top: Scale.x(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transaction',
            style: TextStyle(
              color: Color.fromARGB(239, 100, 100, 100),
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              fontSize: FontSizes.recentTransactions,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: Scale.x(10), bottom: Scale.x(6)),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: TextStyle(
                  color: Colors.black26,
                  fontFamily: 'Open Sans',
                  fontSize: Scale.x(13),
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.navy, size: Scale.x(20)),
                filled: true,
                fillColor: AppColors.grey,
                contentPadding: EdgeInsets.symmetric(vertical: Scale.x(8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Scale.x(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Obx(() {
            if (_repoTransactions.isLoading.value) return _loadingIndicator();
            if (_repoTransactions.tryAgain.value) return _tryAgainIndicator();

            final query = _searchQuery.toLowerCase();
            final filtered = _repoTransactions.data!.where((t) {
              return query.isEmpty ||
                  t['Transaction']?.toString().toLowerCase().contains(query) == true ||
                  t['Date']?.toString().toLowerCase().contains(query) == true ||
                  t['Amount']?.toString().toLowerCase().contains(query) == true ||
                  t['Type']?.toString().toLowerCase().contains(query) == true;
            }).toList();

            if (filtered.isEmpty) return _noRecentTransactionsWidget();

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final transaction = filtered[index];
                return Column(
                  children: [
                    DepositSingleTransaction(
                      date: transaction['Date'],
                      transaction: transaction['Transaction'],
                      type: transaction['Type'],
                      amount: transaction['Amount'],
                      balance: transaction['Balance'],
                    ),
                    index != (filtered.length - 1)
                        ? Container(
                            decoration: const BoxDecoration(color: Colors.blueGrey),
                            child: const SizedBox(height: .5, width: double.infinity),
                          )
                        : const SizedBox(height: 1, width: double.infinity),
                  ],
                );
              },
            );
          })
        ],
      ),
    );
  }

  Widget _loadingIndicator() {
    return SizedBox(
        width: double.infinity,
        height: Scale.x(150),
        child: CircularProgressIndicator.adaptive());
  }

  Widget _tryAgainIndicator() {
    return TryAgain(
      reloadText: 'Try Again',
      onRetry: () async => _repoTransactions.retryData(widget.account),
      height: Scale.x(150),
    );
  }

  Widget _noRecentTransactionsWidget() {
    return Container(
      margin: EdgeInsets.only(
        left: Scale.x(30),
        right: Scale.x(30),
      ),
      width: double.infinity,
      height: Scale.x(300),
      alignment: Alignment.center,
      padding: EdgeInsets.only(
          left: Scale.x(10),
          right: Scale.x(10),
          top: Scale.x(10),
          bottom: Scale.x(40)),
      child: const Text(
        'No recent transactions.',
        style: TextStyle(
          fontFamily: 'Open Sans',
          color: Color.fromARGB(255, 99, 99, 99),
          //fontSize: 24
        ),
      ),
    );
  }
}

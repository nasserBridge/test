import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/credit_transactions/single_creditloan_transaction.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/try_again.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/repositories/transactions_repository.dart';
import 'package:get/get.dart';

class CreditLoanTransactionList extends StatefulWidget {
  final AccountModel account;

  const CreditLoanTransactionList({
    super.key,
    required this.account,
  });

  @override
  State<CreditLoanTransactionList> createState() =>
      _CreditLoanTransactionListState();
}

class _CreditLoanTransactionListState extends State<CreditLoanTransactionList> {
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
    return Container(
      margin: const EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // Offset positions the shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: TextStyle(
              color: Color.fromARGB(239, 100, 100, 100),
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              fontSize: FontSizes.recentTransactions,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: const TextStyle(
                  color: Colors.black26,
                  fontFamily: 'Open Sans',
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.navy, size: 20),
                filled: true,
                fillColor: AppColors.grey,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                  t['Amount']?.toString().toLowerCase().contains(query) == true;
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
                    SingleCreditTransaction(
                      date: transaction['Date'],
                      transaction: transaction['Transaction'],
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
    return const SizedBox(
        width: double.infinity,
        height: 150,
        child: CircularProgressIndicator.adaptive());
  }

  Widget _tryAgainIndicator() {
    return TryAgain(
      reloadText: 'Try Again',
      onRetry: () async => _repoTransactions.retryData(widget.account),
      height: 150,
    );
  }

  Widget _noRecentTransactionsWidget() {
    return Container(
      margin: const EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      width: double.infinity,
      height: 300,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 40),
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

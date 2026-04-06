import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:flutter/material.dart';

class SingleCreditTransaction extends StatelessWidget {
  final String date;
  final String transaction;
  final String amount;
  final String balance;

  const SingleCreditTransaction(
      {super.key,
      required this.date,
      required this.transaction,
      required this.amount,
      required this.balance});

  @override
  Widget build(BuildContext context) {
    // For credit accounts (current), no sign flip in cleanData:
    // positive = purchase (money OUT), negative = credit/refund (money IN)
    // isPayment = negative raw amount = a payment reducing the card balance
    final bool isPayment = amount.startsWith('-');
    final String displayAmount = isPayment
        ? '- ${amount.replaceFirst('-', '')}'
        : amount;
    final Color amountColor = AppColors.transactionBlack;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                      fontFamily: 'Open Sans',
                      color: Color.fromARGB(255, 99, 99, 99),
                      fontSize: FontSizes.transDate),
                ),
                Text(
                  transaction,
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    color: AppColors.green,
                    fontSize: FontSizes.transInfo,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: .35),
                        blurRadius: .5,
                        offset: const Offset(0, .25),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 35,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(displayAmount,
                  style: TextStyle(
                    color: amountColor,
                    fontSize: FontSizes.transAmount,
                    fontWeight: FontWeight.bold,
                  )),
              Text(
                balance,
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: FontSizes.transBalance,
                  color: const Color.fromARGB(255, 99, 99, 99),
                  shadows: [
                    Shadow(
                      color: Colors.grey.withValues(alpha: 0.30),
                      blurRadius: 1,
                      offset: const Offset(0, .25),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ],
      ),
    );
  }
}

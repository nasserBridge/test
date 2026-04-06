import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class DepositSingleTransaction extends StatelessWidget {
  final String date;
  final String transaction;
  final String type;
  final String amount;
  final String balance;
  const DepositSingleTransaction(
      {super.key,
      required this.date,
      required this.transaction,
      required this.type,
      required this.amount,
      required this.balance});

  @override
  Widget build(BuildContext context) {
    // For deposit accounts (available), after the sign flip in cleanData:
    // negative = money OUT (debit), positive = money IN (credit/deposit)
    final bool isMoneyOut = amount.startsWith('-');
    final String displayAmount = isMoneyOut
        ? '- ${amount.replaceFirst('-', '')}'
        : '+ $amount';
    final Color amountColor =
        isMoneyOut ? AppColors.transactionBlack : AppColors.green;

    return Padding(
      padding: EdgeInsets.only(top: Scale.x(12), bottom: Scale.x(12)),
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
                        blurRadius: Scale.x(.5),
                        offset: Offset(Scale.x(0), Scale.x(.25)),
                      )
                    ],
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    color: AppColors.green,
                    fontSize: FontSizes.transType,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: .35),
                        blurRadius: Scale.x(.5),
                        offset: Offset(Scale.x(0), Scale.x(.25)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: Scale.x(35),
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
                      blurRadius: Scale.x(1),
                      offset: Offset(Scale.x(0), Scale.x(.25)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Scale.x(5)),
            ],
          ),
        ],
      ),
    );
  }
}

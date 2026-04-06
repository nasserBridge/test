import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:flutter/material.dart';

class RecentSummary extends StatelessWidget {
  final String accountname;
  final String last4;
  final String balance;

  const RecentSummary({
    super.key,
    required this.accountname,
    required this.last4,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$accountname $last4',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w600,
                    fontSize: FontSizes.accountName,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 0),
            child: Text(
              balance,
              style: TextStyle(
                color: AppColors.navy,
                fontFamily: 'PT Sans',
                fontWeight: FontWeight.w600,
                fontSize: FontSizes.totalBalance,
              ),
            ),
          ),
          Text(
            'Balance',
            style: TextStyle(
              color: Colors.blueGrey,
              fontFamily: 'Raleway',
              fontSize: FontSizes.balancetext,
            ),
          ),
        ],
      ),
    );
  }
}

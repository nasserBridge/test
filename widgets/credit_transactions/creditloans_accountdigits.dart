import 'package:bridgeapp/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';

class CreditLoanAccountDigits extends StatefulWidget {
  final Map<String, dynamic> wires;

  const CreditLoanAccountDigits({super.key, required this.wires});

  @override
  State<CreditLoanAccountDigits> createState() =>
      _CreditLoanAccountDigitsState();
}

class _CreditLoanAccountDigitsState extends State<CreditLoanAccountDigits> {
  bool accountshowing = false;

  void accountVisibility() {
    setState(() {
      accountshowing = !accountshowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30),
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
      width: double.infinity,
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
        children: [
          Row(
            children: [
              Text(
                'Account #',
                style: TextStyle(
                  color: AppColors.navy,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.3,
                  fontSize: FontSizes.accrouteNumber,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: .3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        accountVisibility();
                      },
                      child: accountshowing == false
                          ? const Text('************', textAlign: TextAlign.end)
                          : Text(
                              widget.wires['Account#'],
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: FontSizes.accrouteNumber,
                              ),
                            )))
            ],
          ),
        ],
      ),
    );
  }
}

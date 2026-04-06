import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';

class DepositAccountDigits extends StatefulWidget {
  final Map<String, dynamic> wires;

  const DepositAccountDigits({super.key, required this.wires});

  @override
  State<DepositAccountDigits> createState() => _DepositAccountDigitsState();
}

class _DepositAccountDigitsState extends State<DepositAccountDigits> {
  bool accountshowing = false;

  void accountVisibility() {
    setState(() {
      accountshowing = !accountshowing;
    });
  }

  bool routingshowing = false;

  void routingVisibility() {
    setState(() {
      routingshowing = !routingshowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: Scale.x(30), right: Scale.x(30)),
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Scale.x(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .3),
            spreadRadius: 5,
            blurRadius: 7,
            offset:
                Offset(Scale.x(0), Scale.x(3)), // Offset positions the shadow
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
                      offset: Offset(Scale.x(0), Scale.x(1)),
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
          SizedBox(height: Scale.x(10)),
          Row(
            children: [
              Text(
                'Routing #',
                style: TextStyle(
                  color: AppColors.navy,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.bold,
                  letterSpacing: Scale.x(2.3),
                  fontSize: FontSizes.accrouteNumber,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: .3),
                      blurRadius: Scale.x(2),
                      offset: Offset(Scale.x(0), Scale.x(1)),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        routingVisibility();
                      },
                      child: routingshowing == false
                          ? const Text('************', textAlign: TextAlign.end)
                          : Text(
                              widget.wires['Routing#'],
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

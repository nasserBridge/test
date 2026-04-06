import 'package:bridgeapp/src/features/authentication/screens/accounts/display_extensions/aggregation_display_extension.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/models/aggregation_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/account_aggregation/agg_dropdown.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class SummaryDetails extends StatefulWidget {
  final AggregationModel group;

  const SummaryDetails({
    super.key,
    required this.group,
  });

  @override
  State<SummaryDetails> createState() => _SummaryDetailsState();
}

class _SummaryDetailsState extends State<SummaryDetails> {
  bool buttonExpanded = false;

  @override
  Widget build(BuildContext context) {
    final accountCount = widget.group.accounts.length;

    return GestureDetector(
      onTap: () => setState(() => buttonExpanded = !buttonExpanded),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          SizedBox(height: Scale.x(10)),
          Row(
            children: [
              // Group name + account count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group.groupName,
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizes.accountGroup,
                      letterSpacing: Scale.x(.3),
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    '$accountCount account${accountCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: Scale.x(11),
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.group.combinedBalanceDisplay!,
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: FontSizes.combinedBalance,
                      ),
                    ),
                    SizedBox(width: Scale.x(4)),
                    AnimatedRotation(
                      turns: buttonExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.navy,
                        size: Scale.x(24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          buttonExpanded
              ? Column(
                  children: [
                    SizedBox(height: Scale.x(10)),
                    AggDropdown(group: widget.group),
                    SizedBox(height: Scale.x(10)),
                  ],
                )
              : SizedBox(height: Scale.x(10)),
        ],
      ),
    );
  }
}

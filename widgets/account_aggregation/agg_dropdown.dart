import 'package:bridgeapp/src/features/authentication/screens/accounts/display_extensions/aggregation_display_extension.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/models/aggregation_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/account_aggregation/drop_summary.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class AggDropdown extends StatefulWidget {
  final AggregationModel group;

  const AggDropdown({
    super.key,
    required this.group,
  });

  @override
  State<AggDropdown> createState() => _AggDropdownState();
}

class _AggDropdownState extends State<AggDropdown> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.group.accounts.length,
      separatorBuilder: (_, __) => SizedBox(height: Scale.x(8)),
      itemBuilder: (context, index) {
        final account = widget.group.accounts[index];
        return DropSummary(
          accountgroup: widget.group.groupName,
          combinedbalance: widget.group.combinedBalanceDisplay!,
          account: account,
        );
      },
    );
  }
}

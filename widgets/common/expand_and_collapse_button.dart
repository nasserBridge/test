import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/widgets/shared/icon_ink_response.dart';
import 'package:flutter/material.dart';

class ExpandAndCollapseButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const ExpandAndCollapseButton({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconInkResponse(
            onTap: onToggle,
            icon: isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 28,
          ),
        ],
      ),
    );
  }
}

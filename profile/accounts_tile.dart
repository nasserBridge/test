import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/models/linked_account_model.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class AccountTile extends StatelessWidget {
  final LinkedAccount account;
  final bool isSelected;
  final VoidCallback onTap;

  const AccountTile({
    super.key,
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Scale.x(12)),
      child: Container(
        padding: EdgeInsets.all(Scale.x(16)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Scale.x(12)),
          color: isSelected ? AppColors.navy.withValues(alpha: 0.08) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.navy : Colors.grey.shade300,
            width: isSelected ? Scale.x(2) : Scale.x(1),
          ),
        ),
        child: Row(
          children: [
            // Checkbox indicator
            Container(
              width: Scale.x(24),
              height: Scale.x(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.green : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.navy : Colors.grey.shade400,
                  width: Scale.x(2),
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: Scale.x(12)),
            // Account info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: TextStyle(
                      fontSize: FontSizes.statements,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: Scale.x(4)),
                  Text(
                    "${account.institution} • ${account.type}${account.mask != null ? ' •••• ${account.mask}' : ''}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: FontSizes.statements - 1,
                    ),
                  ),
                ],
              ),
            ),
            // Balance
            Text(
              account.balance,
              style: TextStyle(
                fontSize: FontSizes.statements,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

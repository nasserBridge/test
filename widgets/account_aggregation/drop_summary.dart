import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/display_extensions/account_display_extensions.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/mortgage_viewpage.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/investments/holdings_viewpage.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/savings_transaction_viewpage.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/checking_transaction_viewpage.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/individial_accounts/credit_card_screen.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:bridgeapp/src/features/authentication/controllers/nav_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DropSummary extends StatefulWidget {
  final String accountgroup;
  final String combinedbalance;
  final AccountModel account;

  const DropSummary({
    super.key,
    required this.accountgroup,
    required this.combinedbalance,
    required this.account,
  });

  @override
  State<DropSummary> createState() => _DropSummaryState();
}

class _DropSummaryState extends State<DropSummary> {
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    setState(() {}); // Rebuild to include valid investment info
  }

  bool _shouldShowView() {
    return widget.accountgroup == 'Credit Cards' ||
        widget.accountgroup == 'Checkings' ||
        widget.accountgroup == 'Loans' ||
        widget.accountgroup == 'Savings' ||
        widget.accountgroup == 'Investments';
  }

  void _navigateToView() {
    NavListeners.instance.isOnMain(false);
    if (widget.accountgroup == 'Credit Cards') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CreditCardScreen(accountData: widget.account)));
    } else if (widget.accountgroup == 'Checkings') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              RecentCheckingsTransactionViewPage(accountData: widget.account)));
    } else if (widget.accountgroup == 'Loans') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => MortgageViewPage(accountData: widget.account)));
    } else if (widget.accountgroup == 'Savings') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              RecentSavingsTransactionViewPage(accountData: widget.account)));
    } else if (widget.accountgroup == 'Investments') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => HoldingsViewPage(accountData: widget.account)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Scale.x(12),
        vertical: Scale.x(11),
      ),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(Scale.x(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.account.institution} ${widget.account.accountMaskDisplay}',
                  style: TextStyle(
                    fontSize: FontSizes.dropdownName,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: Scale.x(2)),
                Text(
                  widget.account.accountName,
                  style: TextStyle(
                    fontSize: Scale.x(12),
                    color: AppColors.mediumGrey,
                  ),
                ),
                SizedBox(height: Scale.x(6)),
                Text(
                  widget.account.balanceAmountDisplay,
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizes.dropdownBalance,
                  ),
                ),
              ],
            ),
          ),
          if (_shouldShowView())
            GestureDetector(
              onTapDown: (_) {
                HapticFeedback.lightImpact();
                setState(() => _isPressed = true);
              },
              onTapUp: (_) {
                setState(() => _isPressed = false);
                _navigateToView();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: EdgeInsets.symmetric(
                    horizontal: Scale.x(10),
                    vertical: Scale.x(3),
                  ),
                  decoration: BoxDecoration(
                    color: _isPressed ? AppColors.navy.withValues(alpha: 0.08) : Colors.transparent,
                    border: Border.all(color: AppColors.navy, width: 1.2),
                    borderRadius: BorderRadius.circular(Scale.x(20)),
                  ),
                  child: Text(
                    'View',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizes.viewButton,
                      letterSpacing: Scale.x(0.3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

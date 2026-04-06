import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/accounts_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/widgets/shared/icon_ink_response.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//This class is respoinsble for the Design of the Account Summary Banner

class BannerSummary extends StatefulWidget {
  final String title;

  const BannerSummary({super.key, required this.title});

  @override
  State<BannerSummary> createState() => _BannerSummaryState();
}

class _BannerSummaryState extends State<BannerSummary> {
  final _accountsController = Get.find<AccountsController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Scale.x(10)),
      child: Row(
        children: [
          // Green left accent bar
          Container(
            width: Scale.x(3),
            height: Scale.x(18),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(Scale.x(2)),
            ),
          ),
          SizedBox(width: Scale.x(8)),
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                color: AppColors.navy,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w600,
                letterSpacing: Scale.x(1.5),
                fontSize: FontSizes.statements,
              ),
            ),
          ),
          _updatingIndicator(),
        ],
      ),
    );
  }

  Widget _updatingIndicator() {
    return Obx(() {
      return _accountsController.updatingBalances.value == true
          ? Row(
              children: [
                Text(
                  'Updating',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: Scale.x(1.5),
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: Scale.x(10)),
                CircularProgressIndicator.adaptive(),
              ],
            )
          : _accountsController.updatingBalancesFailed.value == true
              ? Row(
                  children: [
                    Text(
                      'Update Failed',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: Scale.x(1.5),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: Scale.x(5)),
                    IconInkResponse(
                      icon: Icons.refresh,
                      onTap: () =>
                          _accountsController.updateExistingAccounts(null),
                      color: const Color.fromARGB(255, 121, 121, 121),
                      size: 20,
                    )
                  ],
                )
              : SizedBox.shrink();
    });
  }
}

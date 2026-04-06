import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/liabilities/liability_detail.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/loading_indicator.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/try_again.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/liabilities/credit_card_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:get/get.dart';

class CreditDetailsContainer extends StatefulWidget {
  final AccountModel accountData;

  const CreditDetailsContainer({super.key, required this.accountData});

  @override
  State<CreditDetailsContainer> createState() => _CreditDetailsContainerState();
}

class _CreditDetailsContainerState extends State<CreditDetailsContainer> {
  late CreditCardController _controller;

  @override
  void initState() {
    _controller =
        Get.put(CreditCardController(accountData: widget.accountData));
    super.initState();
  }

  @override
  void dispose() {
    _controller.manuallyDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => _controller.bankSupported.value == false ||
            (_controller.isLoading.value == false &&
                _controller.liabilityData.isEmpty == true)
        ? SizedBox.shrink()
        : WhiteContainer(
            margin: const EdgeInsets.only(left: 30, right: 30, top: 20),
            padding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Details',
                  style: TextStyle(
                    color: Color.fromARGB(239, 100, 100, 100),
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    fontSize: FontSizes.statements,
                  ),
                ),
                _controller.isLoading.value == true
                    ? LoadingIndicator(height: 120)
                    : _controller.tryAgain.value == true
                        ? TryAgain(
                            reloadText: 'Try Again',
                            onRetry: () async =>
                                _controller.retryData('credit'),
                            height: 120,
                          )
                        : _controller.liabilityData.isEmpty == false
                            ? Column(
                                children: [
                                  LiabilityDetail(
                                      title: 'Minimum Due',
                                      detail: _controller.liabilityData[
                                          'minimum_payment_amount']),
                                  LiabilityDetail(
                                      title: 'Due Date',
                                      detail: _controller.liabilityData[
                                          'next_payment_due_date']),
                                  LiabilityDetail(
                                      title: 'Last Statement Balance',
                                      detail: _controller.liabilityData[
                                          'last_statement_balance']),
                                  LiabilityDetail(
                                    title: 'Interest Details',
                                    detail: 'View',
                                    aprs: _controller.liabilityData['aprs']
                                        .cast<Map<String, dynamic>>(),
                                  )
                                ],
                              )
                            : LoadingIndicator(height: 120)
              ],
            ),
          ));
  }
}

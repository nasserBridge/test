import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/liabilities/mortgage_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/liabilities/mortgages/payment_calculator.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/loading_indicator.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/try_again.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MortgageCalculatorContainer extends StatefulWidget {
  final AccountModel accountData;

  const MortgageCalculatorContainer({super.key, required this.accountData});

  @override
  State<MortgageCalculatorContainer> createState() =>
      _MortgageCalculatorContainerState();
}

class _MortgageCalculatorContainerState
    extends State<MortgageCalculatorContainer> {
  late MortgageController _controller;

  @override
  void initState() {
    _controller = Get.isRegistered<MortgageController>()
        ? Get.find<MortgageController>()
        : Get.put(MortgageController(accountData: widget.accountData));
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
                _controller.mortgageData.value == null)
        ? SizedBox.shrink()
        : WhiteContainer(
            margin: const EdgeInsets.only(left: 30, right: 30, top: 0),
            padding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Calculator',
                  style: TextStyle(
                      color: Color.fromARGB(239, 100, 100, 100),
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      fontSize: FontSizes.statements),
                ),
                const SizedBox(height: 10),
                _controller.isLoading.value == true
                    ? LoadingIndicator(height: 120)
                    : _controller.tryAgain.value == true
                        ? TryAgain(
                            reloadText: 'Try Again',
                            onRetry: () async =>
                                _controller.retryData('credit'),
                            height: 120,
                          )
                        : _controller.mortgageData.value != null
                            ? PaymentCalculator(
                                mortgageData: _controller.mortgageData.value!,
                              )
                            : SizedBox.shrink(),
              ],
            ),
          ));
  }
}

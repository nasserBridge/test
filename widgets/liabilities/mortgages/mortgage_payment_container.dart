import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/models/account_model.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/liabilities/mortgage_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/liabilities/mortgages/mortgage_payment_details.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/loading_indicator.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/try_again.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MortgagePaymentContainer extends StatefulWidget {
  final AccountModel accountData;

  const MortgagePaymentContainer({super.key, required this.accountData});

  @override
  State<MortgagePaymentContainer> createState() =>
      _MortgagePaymentContainerState();
}

class _MortgagePaymentContainerState extends State<MortgagePaymentContainer> {
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
            margin: EdgeInsets.only(
                left: Scale.x(30), right: Scale.x(30), top: Scale.x(0)),
            padding: EdgeInsets.fromLTRB(
                Scale.x(10), Scale.x(13), Scale.x(23), Scale.x(13)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Payment Details',
                      style: TextStyle(
                          color: Color.fromARGB(239, 100, 100, 100),
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w600,
                          letterSpacing: Scale.x(1.5),
                          fontSize: Scale.x(FontSizes.statements)),
                    ),
                    const Spacer(),
                    _delinquentFlag()
                  ],
                ),
                _controller.isLoading.value == true
                    ? LoadingIndicator(height: Scale.x(120))
                    : _controller.tryAgain.value == true
                        ? TryAgain(
                            reloadText: 'Try Again',
                            onRetry: () async =>
                                _controller.retryData('credit'),
                            height: 120,
                          )
                        : _controller.mortgageData.value != null
                            ? MortgagePaymentDetails(
                                mortgageData: _controller.mortgageData.value!,
                              )
                            : SizedBox.shrink()
              ],
            ),
          ));
  }

  Widget _delinquentFlag() {
    return (_controller.mortgageData.value?.pastDueAmount != null)
        ? Container(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 243, 242, 242),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Past Due',
              style: TextStyle(
                  color: Colors.red.shade800,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ))
        : SizedBox.shrink();
  }
}

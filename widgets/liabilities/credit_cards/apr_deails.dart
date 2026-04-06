import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/liabilities/credit_cards/info_popup.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:flutter/material.dart';

class AprDeails extends StatefulWidget {
  final List<Map<String, dynamic>>? aprs;

  const AprDeails({
    super.key,
    required this.aprs,
  });

  @override
  State<AprDeails> createState() => _AprDeailsState();
}

class _AprDeailsState extends State<AprDeails> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Scrollbar(
        thumbVisibility: true, // Set this to true to always show the scrollbar
        thickness:
            4.0, // Optional: you can adjust the thickness of the scrollbar
        radius: const Radius.circular(
            10), // Optional: make the scrollbar corners round
        controller:
            _scrollController, // Attach ScrollController to the Scrollbar
        child: Container(
          height: 150,
          padding: const EdgeInsets.fromLTRB(15, 0, 12, 0),
          child: ListView.builder(
            controller:
                _scrollController, // Attach ScrollController to ListView
            itemCount: widget.aprs!.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // Return the IconButton as the first item in the list
                return Center(
                  child: IconButton(
                    onPressed: () {
                      InfoPopup.showInfoDialog(
                          context: context,
                          message:
                              'Some institutions may provide incomplete or outdated information.');
                    },
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.navy,
                    ),
                  ),
                );
              }

              final aprItem = widget.aprs![index - 1];
              return Column(
                children: [
                  Row(
                    children: [
                      Text(aprItem['apr_type'] == "balance_transfer_apr"
                          ? 'Balance Transfer APR'
                          : aprItem['apr_type'] == "cash_apr"
                              ? 'Cash Advance APR'
                              : aprItem['apr_type'] == "purchase_apr"
                                  ? 'Purchase APR'
                                  : aprItem['apr_type'] == "special"
                                      ? 'Special APR'
                                      : aprItem['apr_type']),
                      Expanded(
                        child: Text(
                          aprItem['apr_percentage'],
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text('Amount Subject to APR'),
                      Expanded(
                        child: Text(
                          aprItem['balance_subject_to_apr'],
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text('Interest Charged'),
                      Expanded(
                        child: Text(
                          aprItem['interest_charge_amount'],
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  index != widget.aprs!.length
                      ? const Divider()
                      : const Divider() //const SizedBox.shrink(), // Optional: Divider between each item for better readability
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

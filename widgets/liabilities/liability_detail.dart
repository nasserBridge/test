import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/liabilities/credit_cards/apr_deails.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class LiabilityDetail extends StatefulWidget {
  final String title;
  final String detail;
  final TextStyle? detailTextStyle;

  final List<Map<String, dynamic>>? aprs;

  // ✅ NEW
  final Widget? expandedContent;

  const LiabilityDetail({
    super.key,
    required this.title,
    required this.detail,
    this.aprs,
    this.detailTextStyle,
    this.expandedContent, // ✅
  });

  @override
  State<LiabilityDetail> createState() => _LiabilityDetailState();
}

class _LiabilityDetailState extends State<LiabilityDetail> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final isExpandable = widget.expandedContent != null ||
        (widget.title == "Interest Details" &&
            widget.aprs != null &&
            widget.aprs!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  color: const Color.fromARGB(255, 99, 99, 99),
                  fontSize: FontSizes.transDate,
                ),
              ),
              SizedBox(width: Scale.x(60)),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: isExpandable
                      ? () => setState(() => expanded = !expanded)
                      : null,
                  child: Text(
                    expanded && isExpandable ? 'Hide' : widget.detail,
                    textAlign: TextAlign.end,
                    style: widget.detailTextStyle ??
                        TextStyle(
                          fontFamily: 'Open Sans',
                          color: isExpandable
                              ? AppColors.green
                              : const Color.fromARGB(255, 99, 99, 99),
                          fontSize: FontSizes.transDate,
                          decoration: isExpandable
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                  ),
                ),
              ),
            ],
          ),

          //  Expanded content (generic)
          if (expanded && widget.expandedContent != null)
            widget.expandedContent!,

          //  Existing APR behavior preserved
          if (expanded &&
              widget.expandedContent == null &&
              widget.aprs != null &&
              widget.aprs!.isNotEmpty)
            AprDeails(aprs: widget.aprs),
        ],
      ),
    );
  }
}

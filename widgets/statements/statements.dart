import 'package:bridgeapp/src/constants/statement_institutions.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/statements/statement_list_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/expand_and_collapse_button.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/statements/month_statement.dart';
import 'package:bridgeapp/src/features/authentication/screens/onboarding/widgets/white_container.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:get/get.dart';

class Statements extends StatefulWidget {
  final String accountID;
  final String institution;

  const Statements(
      {super.key, required this.accountID, required this.institution});

  @override
  State<Statements> createState() => _StatementsState();
}

class _StatementsState extends State<Statements> {
  final _controller = Get.put(StatementListController());

  @override
  void dispose() {
    _controller.manuallyDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !statementInstituionsList.contains(widget.institution)
        ? SizedBox.shrink()
        : _statementContainer();
  }

  Widget _statementContainer() {
    return WhiteContainer(
      margin: EdgeInsets.only(left: Scale.x(30), right: Scale.x(30), top: 0),
      padding: EdgeInsets.fromLTRB(
          Scale.x(10), Scale.x(13), Scale.x(10), Scale.x(13)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Statements',
                style: TextStyle(
                  color: Color.fromARGB(239, 100, 100, 100),
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  fontSize: FontSizes.statements,
                ),
              ),
              Obx(() => ExpandAndCollapseButton(
                  isExpanded: _controller.buttonExpanded.value,
                  onToggle: _controller.toggleButtonExpanded)),
            ],
          ),
          _statmentList()
        ],
      ),
    );
  }

  Widget _statmentList() {
    return Obx(() => _controller.buttonExpanded.value == false
        ? const SizedBox(height: 0)
        : Scrollbar(
            thumbVisibility:
                true, // Set this to true to always show the scrollbar
            thickness: Scale.x(
                4.0), // Optional: you can adjust the thickness of the scrollbar
            radius: Radius.circular(
                Scale.x(10)), // Optional: make the scrollbar corners round
            controller: _controller
                .scroller, // Attach ScrollController to the Scrollbar
            child: SizedBox(
              height: Scale.x(200),
              child: ListView.builder(
                controller: _controller.scroller,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _controller.recentMonths.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      RequestStatement(
                        month: _controller.recentMonths[index],
                        accountID: widget.accountID,
                        institution: widget.institution,
                      ),
                      index == _controller.recentMonths.length - 1
                          ? SizedBox(height: Scale.x(5))
                          : Container(
                              margin: EdgeInsets.fromLTRB(
                                  Scale.x(12), 0, Scale.x(12), 0),
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey.withValues(alpha: .5)),
                              child: SizedBox(
                                height: Scale.x(.5),
                                width: double.infinity,
                              ),
                            )
                    ],
                  );
                },
              ),
            ),
          ));
  }
}

import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/statements/statement_viewer.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:get/get.dart';

class RequestStatement extends StatelessWidget {
  final String month;
  final String accountID;
  final String institution;

  const RequestStatement({
    super.key,
    required this.month,
    required this.accountID,
    required this.institution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          Scale.x(12), Scale.x(10), Scale.x(12), Scale.x(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            month,
            style: TextStyle(
                fontFamily: 'Open Sans',
                color: Color.fromARGB(255, 99, 99, 99),
                fontSize: FontSizes.statementMonth),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(Scale.x(5)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Scale.x(12)),
                      color: AppColors.grey.withValues(alpha: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .3),
                          spreadRadius: Scale.x(.1),
                          blurRadius: Scale.x(.1),
                          offset: Offset(Scale.x(1),
                              Scale.x(1)), // Offset positions the shadow
                        ),
                      ]),
                  child: GestureDetector(
                      onTap: () {
                        Get.to(() => StatementViewer(
                              accountID: accountID,
                              month: month,
                              institution: institution,
                            ));
                      },
                      child: Text(
                        'VIEW',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: FontSizes.viewStatements,
                        ),
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

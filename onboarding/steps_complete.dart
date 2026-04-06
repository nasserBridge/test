import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class StepsComplete extends StatelessWidget {
  final String onboardingstep;
  final String onboardingstatus;

  const StepsComplete({
    super.key,
    required this.onboardingstep,
    required this.onboardingstatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 1,
          color: AppColors.blue,
        ),
        SizedBox(height: Scale.x(15)),
        Row(
          children: [
            Text(
              onboardingstep,
              style: TextStyle(
                  letterSpacing: Scale.x(1.5),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Raleway',
                  fontSize: FontSizes.stepTitle,
                  color: AppColors.green),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    onboardingstatus,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizes.stepStatus,
                    ),
                  ),
                  SizedBox(width: Scale.x(5)),
                  onboardingstatus == 'Complete'
                      ? const Icon(
                          Icons.done,
                          color: AppColors.green,
                        )
                      : const SizedBox(height: 0)
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: Scale.x(15)),
      ],
    );
  }
}

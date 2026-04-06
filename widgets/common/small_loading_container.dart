import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/constants/font_sizes.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class SmallLoadingContainer extends StatelessWidget {
  const SmallLoadingContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: Scale.x(30), right: Scale.x(30)),
          padding: EdgeInsets.only(
              top: Scale.x(5), bottom: Scale.x(15), left: 0, right: 0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(Scale.x(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .3),
                spreadRadius: Scale.x(5),
                blurRadius: Scale.x(7),
                offset: Offset(0, Scale.x(3)),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: Scale.x(10), top: Scale.x(10)),
                child: Text(
                  'Financial Insights',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.navy, //Color.fromARGB(239, 100, 100, 100),
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: Scale.x(1.5),
                    fontSize: FontSizes.statements,
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  height: Scale.x(83),
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Scale.x(30),
        )
      ],
    );
  }
}

import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class LoadingContainer extends StatefulWidget {
  const LoadingContainer({
    super.key,
  });

  @override
  State<LoadingContainer> createState() => _LoadingContainerState();
}

class _LoadingContainerState extends State<LoadingContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: Scale.x(40),
          bottom: Scale.x(40),
          left: Scale.x(100),
          right: Scale.x(100)),
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(
            height: Scale.x(50),
          ),
          CircularProgressIndicator.adaptive(),
          SizedBox(
            height: Scale.x(50),
          ),
        ],
      ),
    );
  }
}

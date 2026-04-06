import 'dart:io'; // For platform detection
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/apple_pull_to_refresh.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/generic_pull_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // Use ApplePullToRefresh for iOS
      return ApplePullToRefresh(
        onRefresh: onRefresh,
        child: child,
      );
    } else {
      // Use GenericPullRefresh for other platforms
      return GenericPullRefresh(
        onRefresh: onRefresh,
        child: child,
      );
    }
  }
}

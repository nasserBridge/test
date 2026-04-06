import 'package:flutter/cupertino.dart';
import 'package:bridgeapp/src/constants/colors.dart';

class ApplePullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<dynamic> Function() onRefresh;

  const ApplePullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
          refreshTriggerPullDistance: 100.0,
          refreshIndicatorExtent: 0.0,
          builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
            String text = refreshState != RefreshIndicatorMode.done ? "Pull to refresh" : "Refreshing...";
            final double opacity = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);

            return Center(
              child: Opacity(
                opacity: opacity,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.navy,
                  ),
                ),
              ),
            );
          },
        ),
        SliverToBoxAdapter(child: child),
      ],
    );
  }
}

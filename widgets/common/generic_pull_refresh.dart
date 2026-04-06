import 'package:bridgeapp/src/constants/colors.dart';
import 'package:flutter/material.dart';

class GenericPullRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const GenericPullRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  State<GenericPullRefresh> createState() => _GenericPullRefreshState();
}

class _GenericPullRefreshState extends State<GenericPullRefresh>
    with SingleTickerProviderStateMixin {
  double _pullDistance = 0.0;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() async {
    if (_scrollController.offset < 0) {
      setState(() {
        _pullDistance = -_scrollController.offset;
        if (-_scrollController.offset > 100 && _isRefreshing == false) {
          _triggerRefresh();
        }

        if (-_scrollController.offset < 30 && _isRefreshing == true) {
          _isRefreshing = false;
        }
      });
    }
  }

  Future<void> _triggerRefresh() async {
    if (_isRefreshing == true) {
      return;
    }
    _isRefreshing = true;

    await Future.delayed(Duration(milliseconds: 600));
    widget.onRefresh();
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    double opacity = (_pullDistance / 100).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: widget.child,
        ),
        Positioned(
          top: _pullDistance.clamp(0, 15),
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Text(
                _pullDistance > 30 &&
                        _pullDistance < 100 &&
                        _isRefreshing == false
                    ? 'Pull to refresh'
                    : _isRefreshing == true && _pullDistance > 30
                        ? 'Refreshing...'
                        : '',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

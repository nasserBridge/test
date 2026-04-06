import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/controllers/ai_controller.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:get/get.dart';

class ThinkingIndicator extends StatefulWidget {
  const ThinkingIndicator({super.key});

  @override
  State<ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  int dotCount = 0;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<Color?> _colorAnimation;
  final _controller = Get.put(AIController());

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        dotCount = (dotCount + 1) % 4;
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _textScaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: AppColors.navy.withValues(alpha: 0.6),
      end: AppColors.navy,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ((_controller.streamingResponse.value &&
                  _controller.fullAIResponse.isEmpty) ||
              (_controller.streamingResponse.value &&
                  (_controller.fullAIResponse.value ==
                      _controller.visibleAIResponse.value)))
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _colorAnimation,
                      builder: (context, child) {
                        return ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: Scale.x(17),
                            height: Scale.x(17),
                            decoration: BoxDecoration(
                              color: _colorAnimation.value,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: Scale.x(15)),
                    AnimatedBuilder(
                      animation: _textScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _textScaleAnimation.value,
                          child: Text(
                            'Bridgette thinking...', //${'.' * dotCount}',
                            style: TextStyle(
                              color: _colorAnimation.value,
                              fontSize: Scale.x(16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : SizedBox.shrink();
    });
  }
}

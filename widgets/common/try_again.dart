import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class TryAgain extends StatefulWidget {
  final String reloadText;
  final Future<dynamic> Function() onRetry; // Accept a callback for retry logic
  final double height;

  const TryAgain({
    super.key,
    required this.reloadText,
    required this.onRetry, // The callback is required
    required this.height,
  });

  @override
  State<TryAgain> createState() => _TryAgainState();
}

class _TryAgainState extends State<TryAgain> {
  bool _isLoading = false;
  // final _repoBalance = Get.put(BalanceRepository());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Center(
        child: ElevatedButton(
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(0.0),
            backgroundColor:
                WidgetStateColor.resolveWith((states) => AppColors.white),
            // foregroundColor: MaterialStateColor.resolveWith((states) => AppColors.navy),
            //overlayColor: MaterialStateProperty.all(Colors.transparent),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              if (_isLoading) {
                return const Color.fromARGB(
                    255, 181, 181, 181); // Light grey color when pressed
              }
              return AppColors.navy; // Default color
            }),
          ),
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    widget.onRetry(); // Call the provided retry function
                  } catch (e) {
                    // Handle any exceptions if needed
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                color: AppColors.navy,
                Icons.refresh,
                size: Scale.x(35),
              ),
              SizedBox(
                height: Scale.x(10),
              ),
              Text(widget.reloadText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w600,
                    letterSpacing: Scale.x(1.5),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

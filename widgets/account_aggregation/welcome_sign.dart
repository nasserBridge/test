import 'package:bridgeapp/src/constants/colors.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/financial_insights_controller.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/repository/user_repository/user_repository.dart';
import 'package:get/get.dart';

class WelcomeSign extends StatefulWidget {
  const WelcomeSign({super.key});

  @override
  State<WelcomeSign> createState() => _WelcomeSignState();
}

class _WelcomeSignState extends State<WelcomeSign> {
  final _repo = Get.put(UserRepository());
  final _fIController = Get.put(FinancialInsightsController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryMedium],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Obx(() {
        final firstName = _repo.userInfo.value?.firstName;
        final netWorth =
            _fIController.data['Net Worth']?.insight ?? 0.0;
        final assets = _fIController.data['Assets']?.insight ?? 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Greeting row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning,',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: .55),
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: .3,
                      ),
                    ),
                    if (firstName != null)
                      Text(
                        firstName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Balance label
            Text(
              'Total Balance',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: .55),
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            // Balance amount
            Text(
              _formatCurrency(assets > 0 ? assets : netWorth),
              style: const TextStyle(
                color: AppColors.white,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w700,
                fontSize: 38,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            // Change badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC70).withValues(alpha: .2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.trending_up, color: Color(0xFF2ECC71), size: 13),
                  SizedBox(width: 4),
                  Text(
                    '+2.4% this week',
                    style: TextStyle(
                      color: Color(0xFF2ECC71),
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Mini sparkline chart
            SizedBox(
              height: 48,
              child: CustomPaint(
                size: const Size(double.infinity, 48),
                painter: _SparklinePainter(),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatCurrency(double amount) {
    if (amount == 0.0) return '\$0.00';
    final abs = amount.abs();
    final formatted = abs.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return amount < 0 ? '-\$$formatted' : '\$$formatted';
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: .3),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Line
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: .55)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Points normalized to canvas (matches the SVG path from HTML)
    final points = [
      Offset(0, h * .82),
      Offset(w * .11, h * .82),
      Offset(w * .17, h * .45),
      Offset(w * .25, h * .45),
      Offset(w * .33, h * .73),
      Offset(w * .44, h * .36),
      Offset(w * .53, h * .0),
      Offset(w * .66, h * .64),
      Offset(w * .75, h * .50),
      Offset(w * .83, h * .36),
      Offset(w * .91, h * .09),
      Offset(w * .97, h * .23),
      Offset(w, h * .36),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpX = (prev.dx + curr.dx) / 2;
      path.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

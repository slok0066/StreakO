import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double dotRadius;

  DotGridPainter({
    required this.color,
    this.spacing = 16.0,
    this.dotRadius = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StreakCard extends StatefulWidget {
  final int streakCount;
  final String title;

  const StreakCard({
    Key? key,
    required this.streakCount,
    this.title = 'APP STREAK',
  }) : super(key: key);

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.streakCount.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant StreakCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streakCount != widget.streakCount) {
      _animation = Tween<double>(
        begin: oldWidget.streakCount.toDouble(),
        end: widget.streakCount.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final dotColor = isDark
        ? AppColors.darkBorderVisible.withOpacity(0.4)
        : AppColors.lightBorderVisible.withOpacity(0.4);
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Container(
      height: 140.0,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Stack(
          children: [
            // Custom Dot Matrix Background
            Positioned.fill(
              child: CustomPaint(
                painter: DotGridPainter(color: dotColor, spacing: 14.0, dotRadius: 0.8),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title Label
                  Text(
                    widget.title.toUpperCase(),
                    style: GoogleFonts.spaceMono(
                      color: textSecondaryColor,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.08 * 11.0,
                    ),
                  ),
                  // Hero Number and Units Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      // Animated Number
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Text(
                            _animation.value.toInt().toString().padLeft(2, '0'),
                            style: GoogleFonts.doto(
                              color: isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay,
                              fontSize: 52.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.02 * 52.0,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Unit Label
                      Text(
                        'DAYS',
                        style: GoogleFonts.spaceMono(
                          color: AppColors.accent,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.08 * 12.0,
                        ),
                      ),
                    ],
                  ),
                  // Status Info
                  Text(
                    widget.streakCount > 0 ? 'KEEP THE STREAK BURNING' : 'START YOUR FIRST STREAK TODAY',
                    style: GoogleFonts.spaceMono(
                      color: textPrimaryColor,
                      fontSize: 9.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.04 * 9.0,
                    ),
                  ),
                ],
              ),
            ),
            // Hot Red signal point at bottom right
            Positioned(
              bottom: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.streakCount > 0 ? AppColors.success : AppColors.accent,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.streakCount > 0 ? AppColors.success : AppColors.accent).withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

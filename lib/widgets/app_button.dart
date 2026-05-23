import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

enum ButtonVariant { primary, secondary, ghost, destructive }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final double? width;
  final bool isDisabled;

  const AppButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.width,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color textColor;
    BorderSide? borderSide;
    double radius = 999.0; // Pill shape

    switch (variant) {
      case ButtonVariant.primary:
        bg = isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay;
        textColor = isDark ? AppColors.darkBlack : AppColors.lightBlack;
        borderSide = null;
        break;
      case ButtonVariant.secondary:
        bg = Colors.transparent;
        textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        borderSide = BorderSide(
          color: isDark ? AppColors.darkBorderVisible : AppColors.lightBorderVisible,
          width: 1.0,
        );
        break;
      case ButtonVariant.ghost:
        bg = Colors.transparent;
        textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        borderSide = null;
        radius = 0.0;
        break;
      case ButtonVariant.destructive:
        bg = Colors.transparent;
        textColor = AppColors.accent;
        borderSide = const BorderSide(
          color: AppColors.accent,
          width: 1.0,
        );
        break;
    }

    if (isDisabled) {
      bg = Colors.transparent;
      textColor = isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;
      borderSide = BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1.0,
      );
    }

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: SizedBox(
        width: width,
        height: 44.0,
        child: TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            backgroundColor: bg,
            side: borderSide,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceMono(
                color: textColor,
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.06 * 13.0, // 0.06em
              ),
            ),
          ),
        ),
      ),
    );
  }
}

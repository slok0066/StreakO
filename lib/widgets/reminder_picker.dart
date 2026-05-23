import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';

class ReminderPicker extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final ReminderType type;
  final ValueChanged<ReminderType> onTypeChanged;
  final TimeOfDay time;
  final VoidCallback onTimeTap;
  final int intervalMinutes;
  final ValueChanged<int> onIntervalMinutesChanged;

  const ReminderPicker({
    Key? key,
    required this.enabled,
    required this.onEnabledChanged,
    required this.type,
    required this.onTypeChanged,
    required this.time,
    required this.onTimeTap,
    required this.intervalMinutes,
    required this.onIntervalMinutesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderVisibleColor = isDark ? AppColors.darkBorderVisible : AppColors.lightBorderVisible;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceRaisedColor = isDark ? AppColors.darkSurfaceRaised : AppColors.lightSurfaceRaised;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REMINDER'.toUpperCase(),
                    style: GoogleFonts.spaceMono(
                      color: textSecondaryColor,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.08 * 11.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs2),
                  Text(
                    enabled ? 'ACTIVE' : 'INACTIVE',
                    style: GoogleFonts.spaceGrotesk(
                      color: textPrimaryColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              // Technical Switch Control
              Switch(
                value: enabled,
                onChanged: onEnabledChanged,
                activeColor: isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay,
                activeTrackColor: isDark ? AppColors.darkTextDisplay.withOpacity(0.5) : AppColors.lightTextDisplay.withOpacity(0.5),
                inactiveThumbColor: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                inactiveTrackColor: borderVisibleColor,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1.0),
            const SizedBox(height: AppSpacing.md),

            // Segmented Control for Fixed vs Interval
            Container(
              height: 40.0,
              decoration: BoxDecoration(
                border: Border.all(color: borderVisibleColor, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  // Fixed Segment
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onTypeChanged(ReminderType.fixed),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: type == ReminderType.fixed
                              ? (isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(7.0),
                            bottomLeft: Radius.circular(7.0),
                          ),
                        ),
                        child: Text(
                          'FIXED TIME',
                          style: GoogleFonts.spaceMono(
                            color: type == ReminderType.fixed
                                ? (isDark ? AppColors.darkBlack : AppColors.lightBlack)
                                : textSecondaryColor,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.08 * 11.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1.0,
                    color: borderVisibleColor,
                  ),
                  // Interval Segment
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onTypeChanged(ReminderType.interval),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: type == ReminderType.interval
                              ? (isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(7.0),
                            bottomRight: Radius.circular(7.0),
                          ),
                        ),
                        child: Text(
                          'INTERVAL',
                          style: GoogleFonts.spaceMono(
                            color: type == ReminderType.interval
                                ? (isDark ? AppColors.darkBlack : AppColors.lightBlack)
                                : textSecondaryColor,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.08 * 11.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Time Selector (Fixed) or Freq Selector (Interval)
            if (type == ReminderType.fixed) ...[
              GestureDetector(
                onTap: onTimeTap,
                child: Container(
                  height: 48.0,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: surfaceRaisedColor,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TRIGGER AT',
                        style: GoogleFonts.spaceMono(
                          color: textSecondaryColor,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        AppDateUtils.formatTime(time),
                        style: GoogleFonts.spaceMono(
                          color: AppColors.accent,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INTERVAL GAP',
                    style: GoogleFonts.spaceMono(
                      color: textSecondaryColor,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [1, 5, 15, 30, 60, 120, 360, 720].map((minutes) {
                      final isSelected = intervalMinutes == minutes;
                      String label = minutes < 60 ? '${minutes}M' : '${(minutes / 60).round()}H';
                      return OutlinedButton(
                        onPressed: () => onIntervalMinutesChanged(minutes),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          backgroundColor: isSelected
                              ? (isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay)
                              : Colors.transparent,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : borderVisibleColor,
                            width: 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.spaceMono(
                            color: isSelected
                                ? (isDark ? AppColors.darkBlack : AppColors.lightBlack)
                                : textPrimaryColor,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

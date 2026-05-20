import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final borderVisibleColor = isDark ? AppColors.darkBorderVisible : AppColors.lightBorderVisible;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Back Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        border: Border.all(color: borderColor, width: 1.0),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.chevronLeft,
                        size: 20.0,
                        color: textPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'SETTINGS',
                    style: GoogleFonts.spaceMono(
                      color: isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.08 * 18.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // 2. Notifications Section
              _buildCategoryHeader('NOTIFICATIONS', textSecondaryColor),
              _buildSettingsRow(
                context,
                title: 'PERMISSIONS STATUS',
                trailing: Text(
                  provider.notificationPermissionGranted ? 'GRANTED' : 'DENIED',
                  style: GoogleFonts.spaceMono(
                    color: provider.notificationPermissionGranted ? AppColors.success : AppColors.accent,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  if (!provider.notificationPermissionGranted) {
                    provider.requestNotificationPermission();
                  }
                },
                borderColor: borderColor,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Theme Section
              _buildCategoryHeader('SYSTEM APPEARANCE', textSecondaryColor),
              _buildSettingsRow(
                context,
                title: 'THEME MODE',
                trailing: Text(
                  provider.themeMode == ThemeMode.dark ? 'DARK (OLED)' : 'LIGHT (PAPER)',
                  style: GoogleFonts.spaceMono(
                    color: AppColors.accent,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  provider.toggleTheme();
                },
                borderColor: borderColor,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. Database Actions Section
              _buildCategoryHeader('DATABASE ACTIONS', textSecondaryColor),
              _buildSettingsRow(
                context,
                title: 'CLEAR COMPLETED TASKS',
                trailing: Icon(LucideIcons.chevronRight, size: 16.0, color: textSecondaryColor),
                onTap: () => _showClearConfirmationDialog(context, provider),
                borderColor: borderColor,
              ),
              _buildSettingsRow(
                context,
                title: 'RESET ALL ACTIVE STREAKS',
                trailing: Icon(LucideIcons.chevronRight, size: 16.0, color: textSecondaryColor),
                onTap: () => _showResetConfirmationDialog(context, provider),
                borderColor: borderColor,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 5. About StreakO Section
              _buildCategoryHeader('ABOUT STREAKO', textSecondaryColor),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border.all(color: borderColor, width: 1.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Display logo.png inside c:\Users\singh\Downloads\project\StreakO\assets\logo\logo.png
                        // Wrap in a technical frame
                        Container(
                          width: 48.0,
                          height: 48.0,
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderVisibleColor, width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Image.asset(
                            'assets/logo/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Custom mechanical fallback icon if file missing
                              return Icon(
                                LucideIcons.flame,
                                size: 28.0,
                                color: AppColors.accent,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'streakO Mobile',
                              style: GoogleFonts.spaceGrotesk(
                                color: textPrimaryColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'VERSION 1.0.0 (STABLE)',
                              style: GoogleFonts.spaceMono(
                                color: textSecondaryColor,
                                fontSize: 9.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Subtract, don\'t add. A highly premium, monoline task tracking instrument featuring detailed streak counters and fixed/hourly notification alarms designed to comply strictly with the Nothing brand aesthetic.',
                      style: GoogleFonts.spaceGrotesk(
                        color: textSecondaryColor,
                        fontSize: 13.0,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '© 2026 STREAKO LABS. ALL RIGHTS RESERVED.',
                      style: GoogleFonts.spaceMono(
                        color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                        fontSize: 8.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.spaceMono(
          color: color,
          fontSize: 11.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.08 * 11.0,
        ),
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
    required Color borderColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        title: Text(
          title,
          style: GoogleFonts.spaceMono(
            color: textPrimaryColor,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.04 * 12.0,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context, TaskProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: isDark ? AppColors.darkBorderVisible : AppColors.lightBorderVisible,
              width: 1.0,
            ),
          ),
          title: Text(
            'CLEAR COMPLETED TASKS',
            style: GoogleFonts.spaceMono(
              color: isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay,
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to permanently clear all completed tasks from local database?',
            style: GoogleFonts.spaceGrotesk(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontSize: 14.0,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'CANCEL',
                style: GoogleFonts.spaceMono(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'CLEAR ALL',
                style: GoogleFonts.spaceMono(
                  color: AppColors.accent,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {
                provider.clearCompletedTasks();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmationDialog(BuildContext context, TaskProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: isDark ? AppColors.darkBorderVisible : AppColors.lightBorderVisible,
              width: 1.0,
            ),
          ),
          title: Text(
            'RESET ALL STREAKS',
            style: GoogleFonts.spaceMono(
              color: isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay,
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to reset all task streaks and app streaks to zero? This action cannot be undone.',
            style: GoogleFonts.spaceGrotesk(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontSize: 14.0,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'CANCEL',
                style: GoogleFonts.spaceMono(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'RESET',
                style: GoogleFonts.spaceMono(
                  color: AppColors.accent,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {
                provider.resetAllStreaks();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import '../widgets/app_button.dart';
import '../services/streak_service.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final task = provider.getTaskById(taskId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textDisabledColor = isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;
    final borderVisibleColor = isDark ? AppColors.darkBorderVisible : AppColors.lightBorderVisible;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    if (task == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'TASK NOT FOUND',
            style: GoogleFonts.spaceMono(color: AppColors.accent, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Process last 7 days history
    final last7Days = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Back navigation Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Text(
                          'TASK DETAILS',
                          style: GoogleFonts.spaceMono(
                            color: textSecondaryColor,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.08 * 11.0,
                          ),
                        ),
                        // Empty space to balance
                        const SizedBox(width: 40.0),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // 2. Asymmetric Hero Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Priority & Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Priority tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: task.priority == PriorityLevel.high ? AppColors.accent : borderVisibleColor,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  task.priority.name.toUpperCase(),
                                  style: GoogleFonts.spaceMono(
                                    color: task.priority == PriorityLevel.high ? AppColors.accent : textPrimaryColor,
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Title
                              Text(
                                task.title,
                                style: GoogleFonts.spaceGrotesk(
                                  color: isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay,
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),

                        // Right Column: Big Streak Indicator (Doto)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            border: Border.all(color: borderColor, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'STREAK',
                                style: GoogleFonts.spaceMono(
                                  color: textSecondaryColor,
                                  fontSize: 8.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                StreakService.getActiveStreak(task).toString().padLeft(2, '0'),
                                style: GoogleFonts.doto(
                                  color: StreakService.getActiveStreak(task) > 0 ? AppColors.success : AppColors.accent,
                                  fontSize: 36.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(height: 1.0),
                    const SizedBox(height: AppSpacing.lg),

                    // 3. Task Description
                    if (task.description.isNotEmpty) ...[
                      Text(
                        'DESCRIPTION',
                        style: GoogleFonts.spaceMono(
                          color: textSecondaryColor,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.08 * 11.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        task.description,
                        style: GoogleFonts.spaceGrotesk(
                          color: textPrimaryColor,
                          fontSize: 15.0,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(height: 1.0),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // 4. Task Metadata (Technical Instrument Panel rows)
                    _buildInstrumentRow('SCHEDULE', task.repeatType.name.toUpperCase(), textSecondaryColor, textPrimaryColor),
                    if (task.repeatType == RepeatType.custom) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildInstrumentRow(
                        'DUE ON DAYS',
                        task.customDays.map((d) => AppDateUtils.getDayName(d)).join(', '),
                        textSecondaryColor,
                        textPrimaryColor,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    _buildInstrumentRow(
                      'REMINDERS',
                      !task.reminderEnabled
                          ? 'DISABLED'
                          : (task.reminderType == ReminderType.fixed
                              ? 'FIXED: ${AppDateUtils.formatTime(task.reminderTime ?? TimeOfDay.now())}'
                              : 'INTERVAL: EVERY ${task.intervalMinutes! < 60 ? '${task.intervalMinutes} MINUTE(S)' : '${(task.intervalMinutes! / 60).round()} HOUR(S)'}'),
                      textSecondaryColor,
                      task.reminderEnabled ? AppColors.accent : textPrimaryColor,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInstrumentRow('CREATED AT', AppDateUtils.formatDate(task.createdDate), textSecondaryColor, textPrimaryColor),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInstrumentRow(
                      'STATUS',
                      task.isCompleted ? 'COMPLETED' : 'PENDING',
                      textSecondaryColor,
                      task.isCompleted ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(height: 1.0),
                    const SizedBox(height: AppSpacing.lg),

                    // 5. Completion Timeline (Mechanical Segmented Blocks)
                    Text(
                      'COMPLETION HISTORY (LAST 7 DAYS)',
                      style: GoogleFonts.spaceMono(
                        color: textSecondaryColor,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08 * 11.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: last7Days.map((day) {
                        final wasCompleted = task.completionHistory.any((c) => AppDateUtils.isSameDay(c, day));
                        final dayLabel = DateFormat('E').format(day).substring(0, 2).toUpperCase();
                        final dateLabel = DateFormat('d').format(day);
                        final isToday = AppDateUtils.isToday(day);

                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Column(
                              children: [
                                // Mechanical square block
                                Container(
                                  height: 38.0,
                                  decoration: BoxDecoration(
                                    color: wasCompleted
                                        ? AppColors.success
                                        : (isDark ? AppColors.darkSurfaceRaised : AppColors.lightSurfaceRaised),
                                    border: Border.all(
                                      color: isToday
                                          ? (isDark ? Colors.white : Colors.black)
                                          : (wasCompleted ? Colors.transparent : borderVisibleColor),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(4.0), // Technical corner radius
                                  ),
                                  alignment: Alignment.center,
                                  child: wasCompleted
                                      ? const Icon(LucideIcons.check, size: 16.0, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                // Date text label
                                Text(
                                  dayLabel,
                                  style: GoogleFonts.spaceMono(
                                    color: isToday ? textPrimaryColor : textSecondaryColor,
                                    fontSize: 9.0,
                                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  dateLabel,
                                  style: GoogleFonts.spaceMono(
                                    color: isToday ? textPrimaryColor : textDisabledColor,
                                    fontSize: 10.0,
                                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // 6. Action Triggers (Bottom panel)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  top: BorderSide(color: borderColor, width: 1.0),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Primary action: Mark Complete / Undo Complete
                    AppButton(
                      label: task.isCompleted ? 'UNDO COMPLETION' : 'MARK COMPLETED',
                      variant: task.isCompleted ? ButtonVariant.secondary : ButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () {
                        provider.toggleTaskCompletion(task.id);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Secondary action: Edit / Delete
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'EDIT TASK',
                            variant: ButtonVariant.secondary,
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, anim1, anim2) => EditTaskScreen(taskId: task.id),
                                  transitionsBuilder: (context, anim1, anim2, child) {
                                    return FadeTransition(opacity: anim1, child: child);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppButton(
                            label: 'DELETE',
                            variant: ButtonVariant.destructive,
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, task.id, provider);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrumentRow(String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(
            color: labelColor,
            fontSize: 11.0,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.08 * 11.0,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceMono(
            color: valueColor,
            fontSize: 11.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String taskId, TaskProvider provider) {
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
            'DELETE TASK',
            style: GoogleFonts.spaceMono(
              color: isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay,
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to permanently delete this task? This action will reset any streak active on it.',
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
                'DELETE',
                style: GoogleFonts.spaceMono(
                  color: AppColors.accent,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {
                provider.deleteTask(taskId);
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back from details
              },
            ),
          ],
        );
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import '../widgets/streak_card.dart';
import '../widgets/task_card.dart';
import '../widgets/app_button.dart';
import '../services/notification_service.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'task_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription<String> _notificationSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to notification clicks to open detail screen
    _notificationSubscription = NotificationService().onNotificationTap.listen((taskId) {
      _openTaskDetails(taskId);
    });
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  void _openTaskDetails(String taskId) {
    // Find task in provider
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final task = provider.getTaskById(taskId);
    if (task != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => TaskDetailScreen(taskId: taskId),
          transitionsBuilder: (context, anim1, anim2, child) {
            return FadeTransition(opacity: anim1, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderVisibleColor = isDark ? AppColors.darkBorderVisible : AppColors.lightBorderVisible;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Hot reload/refresh tasks
            provider.refreshTasks();
          },
          color: AppColors.accent,
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Area
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppDateUtils.formatDate(DateTime.now()),
                          style: GoogleFonts.spaceMono(
                            color: textSecondaryColor,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.08 * 11.0,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 32.0,
                              height: 32.0,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceRaised : AppColors.lightSurfaceRaised,
                                border: Border.all(
                                  color: borderVisibleColor,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7.0),
                                child: Image.asset(
                                  'assets/logo/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      LucideIcons.flame,
                                      size: 16.0,
                                      color: AppColors.accent,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'StreakO',
                              style: GoogleFonts.spaceGrotesk(
                                color: isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay,
                                fontSize: 28.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Theme Switcher Button
                        IconButton(
                          icon: Icon(
                            isDark ? LucideIcons.sun : LucideIcons.moon,
                            color: textPrimaryColor,
                            size: 22.0,
                          ),
                          onPressed: () {
                            provider.toggleTheme();
                          },
                          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                        ),
                        // Settings Gear Button
                        IconButton(
                          icon: Icon(
                            LucideIcons.settings,
                            color: textPrimaryColor,
                            size: 22.0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, anim1, anim2) => const SettingsScreen(),
                                transitionsBuilder: (context, anim1, anim2, child) {
                                  return FadeTransition(opacity: anim1, child: child);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Streak Widget
                StreakCard(streakCount: provider.totalAppStreak),
                const SizedBox(height: AppSpacing.md),

                // 3. Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          border: Border.all(color: borderColor, width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'COMPLETED TODAY',
                              style: GoogleFonts.spaceMono(
                                color: textSecondaryColor,
                                fontSize: 9.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.08 * 9.0,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              provider.totalCompletedToday.toString().padLeft(2, '0'),
                              style: GoogleFonts.spaceMono(
                                color: isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay,
                                fontSize: 28.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          border: Border.all(color: borderColor, width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PENDING TASKS',
                              style: GoogleFonts.spaceMono(
                                color: textSecondaryColor,
                                fontSize: 9.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.08 * 9.0,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              provider.pendingCount.toString().padLeft(2, '0'),
                              style: GoogleFonts.spaceMono(
                                color: provider.pendingCount > 0 ? AppColors.accent : textPrimaryColor,
                                fontSize: 28.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // 4. Section Divider Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YOUR TASKS'.toUpperCase(),
                      style: GoogleFonts.spaceMono(
                        color: textSecondaryColor,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08 * 11.0,
                      ),
                    ),
                    // Active filter indicator text
                    Text(
                      '${provider.filteredTasks.length} ITEMS',
                      style: GoogleFonts.spaceMono(
                        color: textSecondaryColor,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // 5. Filter Tags row
                SizedBox(
                  height: 34.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: TaskFilter.values.map((filter) {
                      final isSelected = provider.currentFilter == filter;
                      String label = filter.name.toUpperCase();
                      if (filter == TaskFilter.high) label = 'HIGH PRIORITY';

                      return Container(
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        child: GestureDetector(
                          onTap: () => provider.setFilter(filter),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay)
                                    : borderVisibleColor,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(999.0),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.spaceMono(
                                color: isSelected
                                    ? (isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay)
                                    : textSecondaryColor,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.04 * 10.0,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 6. Tasks List or Empty State
                if (provider.filteredTasks.isEmpty)
                  _buildEmptyState(context, isDark, textSecondaryColor, provider)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = provider.filteredTasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, anim1, anim2) => TaskDetailScreen(taskId: task.id),
                              transitionsBuilder: (context, anim1, anim2, child) {
                                return FadeTransition(opacity: anim1, child: child);
                              },
                            ),
                          );
                        },
                        onToggleComplete: () {
                          provider.toggleTaskCompletion(task.id);
                        },
                        onEdit: () {
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
                        onDelete: () {
                          _showDeleteConfirmationDialog(context, task.id, provider);
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, anim1, anim2) => const AddTaskScreen(),
              transitionsBuilder: (context, anim1, anim2, child) {
                return FadeTransition(opacity: anim1, child: child);
              },
            ),
          );
        },
        backgroundColor: isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay,
        shape: const CircleBorder(),
        elevation: 0,
        child: Icon(
          LucideIcons.plus,
          color: isDark ? AppColors.darkBlack : AppColors.lightBlack,
          size: 24.0,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, Color textSecondaryColor, TaskProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl3),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.calendarCheck,
            size: 48.0,
            color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No tasks yet'.toUpperCase(),
            style: GoogleFonts.spaceMono(
              color: textSecondaryColor,
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.08 * 13.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Add your first task and start your streak.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'ADD FIRST TASK',
            width: 200,
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, anim1, anim2) => const AddTaskScreen(),
                  transitionsBuilder: (context, anim1, anim2, child) {
                    return FadeTransition(opacity: anim1, child: child);
                  },
                ),
              );
            },
          ),
        ],
      ),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

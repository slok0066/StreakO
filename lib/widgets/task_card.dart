import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final borderVisibleColor = isDark ? AppColors.darkBorderVisible : AppColors.lightBorderVisible;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textDisabledColor = isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;

    // Priority color mapping
    Color priorityBorderColor = borderVisibleColor;
    Color priorityTextColor = textSecondaryColor;
    if (widget.task.priority == PriorityLevel.high) {
      priorityBorderColor = AppColors.accent;
      priorityTextColor = AppColors.accent;
    } else if (widget.task.priority == PriorityLevel.medium) {
      priorityTextColor = textPrimaryColor;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: widget.task.isCompleted
                  ? borderColor
                  : (widget.task.priority == PriorityLevel.high ? AppColors.accent.withOpacity(0.3) : borderColor),
              width: 1.0,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Priority tag & Streak Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Priority Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: priorityBorderColor, width: 1.0),
                          borderRadius: BorderRadius.circular(4.0), // Technical radius
                        ),
                        child: Text(
                          widget.task.priority.name.toUpperCase(),
                          style: GoogleFonts.spaceMono(
                            color: priorityTextColor,
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.04 * 9.0,
                          ),
                        ),
                      ),
                      // Streak Count Indicator
                      if (widget.task.repeatType != RepeatType.none)
                        Row(
                          children: [
                            Text(
                              '[STRK: ${widget.task.streakCount.toString().padLeft(2, '0')}]',
                              style: GoogleFonts.spaceMono(
                                color: widget.task.streakCount > 0 ? AppColors.success : textSecondaryColor,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.04 * 10.0,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Middle Row: Checkbox, Title & Description
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom tactile mechanical checkbox with generous touch target
                      GestureDetector(
                        onTap: widget.onToggleComplete,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14.0, bottom: 12.0, top: 2.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 24.0,
                            height: 24.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: widget.task.isCompleted ? AppColors.success : borderVisibleColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                              color: widget.task.isCompleted ? AppColors.success.withOpacity(0.15) : Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: widget.task.isCompleted
                                ? const Icon(
                                    LucideIcons.check,
                                    size: 16.0,
                                    color: AppColors.success,
                                  )
                                : null,
                          ),
                        ),
                      ),

                      // Task Text contents
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.task.title,
                              style: GoogleFonts.spaceGrotesk(
                                color: widget.task.isCompleted ? textDisabledColor : textPrimaryColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (widget.task.description.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                widget.task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.spaceGrotesk(
                                  color: textSecondaryColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w400,
                                  decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(height: 1.0),
                  const SizedBox(height: AppSpacing.sm),

                  // Bottom Row: Metadata & Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Reminder info and repeat type
                      Expanded(
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Reminder Time
                            if (widget.task.reminderEnabled)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.bell,
                                    size: 12.0,
                                    color: textSecondaryColor,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    widget.task.reminderType == ReminderType.fixed
                                        ? AppDateUtils.formatTime(widget.task.reminderTime ?? TimeOfDay.now())
                                        : 'EVERY ${widget.task.intervalHours}H',
                                    style: GoogleFonts.spaceMono(
                                      color: textSecondaryColor,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            // Repeat Label
                            if (widget.task.repeatType != RepeatType.none)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: borderColor, width: 1.0),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                child: Text(
                                  widget.task.repeatType.name.toUpperCase(),
                                  style: GoogleFonts.spaceMono(
                                    color: textSecondaryColor,
                                    fontSize: 8.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Controls (Edit / Delete)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.edit3, size: 16.0),
                            color: textSecondaryColor,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: widget.onEdit,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 16.0),
                            color: AppColors.accent.withOpacity(0.7),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: widget.onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

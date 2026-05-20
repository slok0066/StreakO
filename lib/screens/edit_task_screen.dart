import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import '../widgets/app_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/reminder_picker.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;

  const EditTaskScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  PriorityLevel _selectedPriority = PriorityLevel.medium;
  RepeatType _selectedRepeat = RepeatType.none;
  List<int> _customDays = [];

  bool _reminderEnabled = false;
  ReminderType _reminderType = ReminderType.fixed;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 12, minute: 0);
  int _intervalHours = 1;

  String? _titleError;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final provider = Provider.of<TaskProvider>(context, listen: false);
      final task = provider.getTaskById(widget.taskId);

      if (task != null) {
        _titleController.text = task.title;
        _descriptionController.text = task.description;
        _selectedPriority = task.priority;
        _selectedRepeat = task.repeatType;
        _customDays = List<int>.from(task.customDays);
        _reminderEnabled = task.reminderEnabled;
        _reminderType = task.reminderType;
        if (task.reminderTime != null) {
          _reminderTime = task.reminderTime!;
        }
        if (task.intervalHours != null) {
          _intervalHours = task.intervalHours!;
        }
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleCustomDay(int day) {
    setState(() {
      if (_customDays.contains(day)) {
        _customDays.remove(day);
      } else {
        _customDays.add(day);
      }
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.accent,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.accent,
                    surface: AppColors.lightSurface,
                    onSurface: AppColors.lightTextPrimary,
                  ),
            dialogBackgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _reminderTime = pickedTime;
      });
    }
  }

  void _saveTask() {
    setState(() {
      _titleError = null;
    });

    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _titleError = 'Task title is required';
      });
      return;
    }

    final provider = Provider.of<TaskProvider>(context, listen: false);
    final task = provider.getTaskById(widget.taskId);

    if (task == null) return;

    final updatedTask = task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      reminderEnabled: _reminderEnabled,
      reminderTime: _reminderType == ReminderType.fixed ? _reminderTime : null,
      reminderType: _reminderType,
      intervalHours: _reminderType == ReminderType.interval ? _intervalHours : null,
      repeatType: _selectedRepeat,
      customDays: _selectedRepeat == RepeatType.custom ? _customDays : const [],
      priority: _selectedPriority,
      updatedDate: DateTime.now(),
    );

    provider.updateTask(updatedTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderVisibleColor = isDark ? AppColors.darkBorderVisible : AppColors.lightBorderVisible;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Back button & Title Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1.0,
                        ),
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
                    'EDIT TASK',
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

              // 2. Input Fields
              CustomTextField(
                label: 'Title',
                placeholder: 'Enter task name...',
                controller: _titleController,
                errorText: _titleError,
              ),
              const SizedBox(height: AppSpacing.lg),
              CustomTextField(
                label: 'Description (Optional)',
                placeholder: 'Enter supporting details...',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Priority Selector
              Text(
                'PRIORITY',
                style: GoogleFonts.spaceMono(
                  color: textSecondaryColor,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08 * 11.0,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: PriorityLevel.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  Color activeColor = isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay;
                  if (priority == PriorityLevel.high) {
                    activeColor = AppColors.accent;
                  }

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected ? activeColor : Colors.transparent,
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : borderVisibleColor,
                            width: 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          priority.name.toUpperCase(),
                          style: GoogleFonts.spaceMono(
                            color: isSelected
                                ? (priority == PriorityLevel.high
                                    ? Colors.white
                                    : (isDark ? AppColors.darkBlack : AppColors.lightBlack))
                                : textPrimaryColor,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. Repeat Selector
              Text(
                'REPEAT',
                style: GoogleFonts.spaceMono(
                  color: textSecondaryColor,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.08 * 11.0,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: RepeatType.values.map((repeat) {
                  final isSelected = _selectedRepeat == repeat;
                  String label = repeat.name.toUpperCase();
                  if (repeat == RepeatType.none) label = 'SINGLE';

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedRepeat = repeat;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: isSelected
                              ? (isDark ? AppColors.darkTextDisplay : AppColors.lightTextDisplay)
                              : Colors.transparent,
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : borderVisibleColor,
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
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // 4.1 Custom Days Selector (Indentated)
              if (_selectedRepeat == RepeatType.custom) ...[
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SELECT CUSTOM DAYS',
                        style: GoogleFonts.spaceMono(
                          color: textSecondaryColor,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final dayNum = index + 1;
                          final isSelected = _customDays.contains(dayNum);
                          final dayName = AppDateUtils.getDayName(dayNum);

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _toggleCustomDay(dayNum),
                              child: Container(
                                height: 36.0,
                                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accent
                                      : (isDark ? AppColors.darkSurfaceRaised : AppColors.lightSurfaceRaised),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : borderVisibleColor,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  dayName,
                                  style: GoogleFonts.spaceMono(
                                    color: isSelected ? Colors.white : textPrimaryColor,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              // 5. Reminder Picker
              ReminderPicker(
                enabled: _reminderEnabled,
                onEnabledChanged: (val) {
                  setState(() {
                    _reminderEnabled = val;
                  });
                },
                type: _reminderType,
                onTypeChanged: (type) {
                  setState(() {
                    _reminderType = type;
                  });
                },
                time: _reminderTime,
                onTimeTap: () => _selectTime(context),
                intervalHours: _intervalHours,
                onIntervalHoursChanged: (hours) {
                  setState(() {
                    _intervalHours = hours;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // 6. Action Button
              AppButton(
                label: 'SAVE CHANGES',
                width: double.infinity,
                onPressed: _saveTask,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

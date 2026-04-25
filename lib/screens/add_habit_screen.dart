import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/dotted_background.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedIcon = '🏃';
  int _selectedColorIndex = 0;
  TimeOfDay? _reminderTime;

  final List<String> _icons = [
    '🏃', '📚', '💧', '🧘', '🏋️', '🥗',
    '💻', '🎨', '📝', '🎸', '🌱', '🌙',
    '🧹', '☕', '🚴', '🤸', '🎯', '💊',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    DateTime? reminderDateTime;
    if (_reminderTime != null) {
      final now = DateTime.now();
      reminderDateTime = DateTime(
          now.year, now.month, now.day, _reminderTime!.hour, _reminderTime!.minute);
    }

    final habit = Habit()
      ..id = const Uuid().v4()
      ..title = _titleController.text.trim()
      ..description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim()
      ..icon = _selectedIcon
      ..colorValue = AppColors.habitColors[_selectedColorIndex].toARGB32()
      ..reminderTime = reminderDateTime
      ..createdAt = DateTime.now()
      ..completedDates = [];

    ref.read(habitProvider.notifier).addHabit(habit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('INITIALIZE_HABIT'),
      ),
      body: DottedBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(32),
            children: [
              // Title
              Text(
                'IDENTIFIER',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  hintText: 'E.G. MORNING_RUN',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'FIELD_REQUIRED' : null,
              ),
              const SizedBox(height: 32),
              // Description
              Text(
                'PARAMETERS',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                style: GoogleFonts.spaceGrotesk(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'OPTIONAL_DATA_FIELD',
                ),
              ),
              const SizedBox(height: 48),
              // Icon picker
              Text(
                'GLYPH_SELECTION',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _icons.map((icon) {
                  final sel = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: sel ? scheme.onSurface : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: sel
                              ? scheme.onSurface
                              : scheme.onSurface.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: TextStyle(
                            fontSize: 24,
                            color: sel ? scheme.surface : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              // Color picker
              Text(
                'ACCENT_CODE',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(AppColors.habitColors.length, (i) {
                  final sel = _selectedColorIndex == i;
                  final color = AppColors.habitColors[i];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = i),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: sel ? scheme.onSurface : Colors.transparent,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),
              // Reminder
              Text(
                'ALERT_SCHEDULING',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                child: ListTile(
                  onTap: () async {
                    final t = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (t != null) setState(() => _reminderTime = t);
                  },
                  leading: Icon(Icons.alarm,
                      size: 18,
                      color: _reminderTime != null
                          ? scheme.onSurface
                          : scheme.onSurface.withValues(alpha: 0.2)),
                  title: Text(
                    _reminderTime != null
                        ? _reminderTime!.format(context).toUpperCase()
                        : 'NO_ALERTS_ACTIVE',
                    style: GoogleFonts.spaceMono(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: _reminderTime != null
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => setState(() => _reminderTime = null),
                        )
                      : const Icon(Icons.chevron_right, size: 16),
                ),
              ),
              const SizedBox(height: 64),
              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _saveHabit,
                  child: const Text('EXECUTE_INITIALIZATION'),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

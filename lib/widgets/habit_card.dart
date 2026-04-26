import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class HabitCard extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.habit.isCompletedToday;
    final color = Color(widget.habit.colorValue);
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        Slidable(
          endActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) =>
                    ref.read(habitProvider.notifier).deleteHabit(widget.habit),
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
                icon: Icons.delete_outline,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutExpo,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? scheme.onSurface.withValues(alpha: 0.02) 
                  : scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCompleted
                    ? scheme.onSurface.withValues(alpha: 0.05)
                    : scheme.onSurface.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                if (!isCompleted) _confettiController.play();
                ref.read(habitProvider.notifier).toggleHabitCompletion(
                      widget.habit.id,
                      DateTime.now(),
                    );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Icon/Glyph with subtle dot-matrix background
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          widget.habit.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title/Meta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.habit.title.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: isCompleted
                                  ? scheme.onSurface.withValues(alpha: 0.3)
                                  : scheme.onSurface,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                (widget.habit.description ?? 'NO_DESCRIPTION_LOGGED').toUpperCase(),
                                style: GoogleFonts.spaceMono(
                                  fontSize: 10,
                                  color: scheme.onSurface.withValues(alpha: 0.4),
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '//',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: scheme.onSurface.withValues(alpha: 0.2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'STRK_${widget.habit.streak.toString().padLeft(3, '0')}',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: widget.habit.streak > 0
                                      ? scheme.secondary
                                      : scheme.onSurface.withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Checkbox (Mechanical / Dot Matrix inspired)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted ? scheme.onSurface : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: isCompleted
                              ? scheme.onSurface
                              : scheme.onSurface.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                      ),
                      child: isCompleted
                          ? Center(
                              child: Icon(
                                Icons.square,
                                color: scheme.surface,
                                size: 12,
                              ),
                            )
                          : Center(
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: scheme.onSurface.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: [scheme.onSurface, scheme.error, color],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/habit_provider.dart';
import '../widgets/dotted_background.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitStreamProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('STATISTICS // ANALYTICS'),
      ),
      body: DottedBackground(
        child: habitsAsync.when(
          data: (habits) {
            if (habits.isEmpty) {
              return Center(
                child: Text(
                  'NO_DATA_AVAILABLE',
                  style: GoogleFonts.spaceMono(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              );
            }

            final completedToday =
                habits.where((h) => h.isCompletedToday).length;
            final total = habits.length;
            final completionRate = total > 0 ? completedToday / total : 0.0;
            final totalCompletions = habits.fold<int>(
                0, (sum, h) => sum + h.completedDates.length);
            final maxStreak =
                habits.fold<int>(0, (m, h) => h.streak > m ? h.streak : m);

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Today's progress (Technical Hero)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: scheme.onSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT_SYNC_RATE',
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: scheme.surface.withValues(alpha: 0.6),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${(completionRate * 100).toInt()}',
                            style: GoogleFonts.doto(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: scheme.surface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '%',
                            style: GoogleFonts.spaceMono(
                              fontSize: 24,
                              color: scheme.surface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: List.generate(20, (index) {
                          final isFilled = completionRate >= (index + 1) / 20;
                          return Expanded(
                            child: Container(
                              height: 6,
                              margin:
                                  EdgeInsets.only(right: index == 19 ? 0 : 2),
                              color: isFilled
                                  ? scheme.surface
                                  : scheme.surface.withValues(alpha: 0.1),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'MAX_STREAK',
                        value: '$maxStreak',
                        unit: 'DAYS',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'TOTAL_HITS',
                        value: '$totalCompletions',
                        unit: 'OPS',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Text(
                  'INDIVIDUAL_METRICS',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 16),
                ...habits.map((h) {
                  final hRate = h.completedDates.length;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      border: Border.all(
                        color: scheme.onSurface.withValues(alpha: 0.05),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(h.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            h.title.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          '${hRate.toString().padLeft(3, '0')}',
                          style: GoogleFonts.spaceMono(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'OPS',
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            color: scheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 1)),
          error: (e, _) => Center(child: Text('ERROR: $e')),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceMono(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  color: scheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

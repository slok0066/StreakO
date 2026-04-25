import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/dotted_background.dart';
import 'add_habit_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitStreamProvider);
    final themeMode = ref.watch(themeModeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo/logo.png',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 12),
            const Text('STREAKO // SYSTEM'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: () =>
                ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DottedBackground(
        child: habitsAsync.when(
          data: (habits) {
            final completed = habits.where((h) => h.isCompletedToday).length;
            final total = habits.length;
            final progress = total > 0 ? (completed / total) : 0.0;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAILY_CAPACITY',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${(progress * 100).toInt()}',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '%',
                              style: GoogleFonts.spaceMono(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Segmented Progress Bar
                        Row(
                          children: List.generate(10, (index) {
                            final isFilled = progress >= (index + 1) / 10;
                            return Expanded(
                              child: Container(
                                height: 4,
                                margin: EdgeInsets.only(
                                    right: index == 9 ? 0 : 4),
                                decoration: BoxDecoration(
                                  color: isFilled
                                      ? scheme.onSurface
                                      : scheme.onSurface.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          total == 0
                              ? 'AWAITING_INPUT'
                              : completed == total
                                  ? 'OPTIMAL_STATE_REACHED'
                                  : '$completed OF $total TASKS_SYNCED',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                if (habits.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: scheme.onSurface.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'NO_HABITS_DETECTED',
                            style: GoogleFonts.spaceMono(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: scheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HabitCard(habit: habits[i]),
                        ),
                        childCount: habits.length,
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 1)),
          error: (e, _) => Center(child: Text('ERROR: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddHabitScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

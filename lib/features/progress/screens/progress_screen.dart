import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/progress_provider.dart';
import '../widgets/weekly_chart.dart';
import '../../log/providers/workout_provider.dart';
import '../../log/models/workout_entry.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(workoutNotifierProvider);
    final notifier = ref.watch(progressNotifierProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: workoutAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (entries) {
            final dailyVolumes = List.generate(7, (i) {
              final date = DateTime.now().subtract(Duration(days: 6 - i));
              return notifier.getDailyVolume(date, entries);
            });

            final prs = notifier.getPersonalRecords(entries);
            final streak = notifier.getWeeklyStreak(entries);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'YOUR PROGRESS',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                  ).animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 24),
                  
                  // UPGRADED: Weekly Volume Chart
                  WeeklyChart(dailyVolumes: dailyVolumes)
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .scale(begin: const Offset(0.95, 0.95)),
                  const SizedBox(height: 32),

                  // UPGRADED: Consistency Heatmap
                  _ConsistencyHeatmap(entries: entries).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'VOLUME',
                          value: '${(dailyVolumes.fold(0.0, (s, v) => s + v) / 1000).toStringAsFixed(1)}T',
                          icon: Icons.fitness_center,
                          delay: 400,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: 'CONSISTENCY',
                          value: '${streak}D',
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                          delay: 500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  _PRSection(prs: prs).animate().fadeIn(delay: 600.ms),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConsistencyHeatmap extends StatelessWidget {
  final List<WorkoutEntry> entries;
  const _ConsistencyHeatmap({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONSISTENCY',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 10, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final date = DateTime.now().subtract(Duration(days: 6 - i));
              final hasWorkout = entries.any((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day);
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: hasWorkout ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(hasWorkout ? 0 : 0.1)),
                    ),
                    child: hasWorkout ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('E').format(date).substring(0, 1),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: hasWorkout ? AppColors.primary : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PRSection extends StatelessWidget {
  final Map<String, double> prs;
  const _PRSection({required this.prs});

  @override
  Widget build(BuildContext context) {
    if (prs.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PERSONAL RECORDS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12, color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 16),
        ...prs.entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('${e.value.toStringAsFixed(1)} KG', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final int delay;

  const _StatCard({required this.label, required this.value, required this.icon, this.color, required this.delay});

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight, letterSpacing: 1)),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

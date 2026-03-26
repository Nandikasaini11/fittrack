import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fittrack/features/log/providers/workout_provider.dart';
import 'package:fittrack/features/progress/providers/progress_provider.dart';
import 'package:fittrack/shared/widgets/animated_counter.dart';
import 'package:fittrack/core/constants/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Color _getGreetingColor() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Colors.orangeAccent;
    if (hour < 17) return Colors.blueAccent;
    return Colors.deepPurpleAccent;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(workoutNotifierProvider);
    final progressNotifier = ref.watch(progressNotifierProvider.notifier);
    
    return Scaffold(
      body: workoutAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allEntries) {
          final now = DateTime.now();
          final todayEntries = allEntries.where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day
          ).toList();
          
          final streak = progressNotifier.getWeeklyStreak(allEntries);
          final todayVolume = progressNotifier.getDailyVolume(now, allEntries);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                collapsedHeight: 80,
                pinned: true,
                stretch: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getGreetingColor().withOpacity(0.8),
                          _getGreetingColor().withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 80,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                  titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white70,
                        ),
                      ),
                      const Text(
                        'Warrior',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _QuickStatCard(
                                label: 'STREAK',
                                value: streak,
                                suffix: ' days',
                                icon: Icons.local_fire_department,
                                color: Colors.orange,
                              ),
                              _QuickStatCard(
                                label: 'VOLUME',
                                value: todayVolume.toInt(),
                                suffix: ' kg',
                                icon: Icons.fitness_center,
                                color: Colors.blue,
                              ),
                              _QuickStatCard(
                                label: 'TOTAL',
                                value: allEntries.length,
                                suffix: ' logs',
                                icon: Icons.history_rounded,
                                color: Colors.deepPurple,
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                      
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 30),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "TODAY'S FOCUS",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 1.2,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const Text(
                                        "Stay Consistent",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                    ],
                  ),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'DAILY SUMMARY',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _SummaryCard(title: 'Exercises', value: '${todayEntries.length}', icon: Icons.fitness_center, delayMs: 300),
                          _SummaryCard(title: 'Sets', value: '${todayEntries.fold(0, (s, e) => s + e.sets)}', icon: Icons.repeat, delayMs: 400),
                          _SummaryCard(title: 'Reps', value: '${todayEntries.fold(0, (s, e) => s + e.reps)}', icon: Icons.replay, delayMs: 500),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final int delayMs;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn(delay: delayMs.ms).scale();
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final IconData icon;
  final Color color;

  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          AnimatedCounter(
            value: value,
            suffix: suffix,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondaryLight,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}

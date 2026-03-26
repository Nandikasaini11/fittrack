import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_provider.dart';
import '../widgets/add_exercise_form.dart';
import '../widgets/exercise_tile.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import 'package:lottie/lottie.dart';
import '../../../shared/widgets/particle_burst.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  final GlobalKey<ParticleBurstState> _particleKey = GlobalKey<ParticleBurstState>();

  void _showAddExerciseSheet() {
    // UPGRADED: Custom Bottom Sheet with DraggableScrollableSheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        snap: true,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: AddExerciseForm(
            onSubmitted: () {
              Navigator.pop(context);
              _particleKey.currentState?.burst();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutAsync = ref.watch(workoutNotifierProvider);
    final todayEntries = workoutAsync.todayEntries;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExerciseSheet,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('LOG WORKOUT', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 8,
      ).animate().scale(delay: 500.ms),
      body: ParticleBurst(
        key: _particleKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              expandedHeight: 120,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'WORKOUT LOG',
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight),
                ),
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TODAY'S ACTIVITY",
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${todayEntries.length} Exercises',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            workoutAsync.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
              data: (_) => todayEntries.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // UPGRADED: Lottie Animation for Empty State
                            Lottie.network(
                              'https://assets9.lottiefiles.com/packages/lf20_m6cuL6.json',
                              width: 200,
                              repeat: true,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'YOUR GRIND STARTS HERE',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppColors.textSecondaryLight,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ExerciseTile(
                            entry: todayEntries[index],
                            onDelete: () => ref.read(workoutNotifierProvider.notifier).deleteEntry(todayEntries[index].id),
                            index: index,
                          ),
                          childCount: todayEntries.length,
                        ),
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/exercise_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/category_tag.dart';
import 'package:flutter/services.dart';
import '../../log/providers/workout_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseCard extends ConsumerWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  final int index;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
    this.index = 0,
  });

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    // UPGRADED: Medium Impact Haptic Feedback for premium feel
    HapticFeedback.mediumImpact();

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    // UPGRADED: Custom Styled Context Menu
    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      items: [
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.add_circle_outline, color: AppColors.primary),
            title: Text('Add to today', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          onTap: () {
            ref.read(workoutNotifierProvider.notifier).addEntry(
              name: exercise.name,
              sets: 3, // Default values for quick add
              reps: 10,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${exercise.name} to today'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.visibility_outlined),
            title: Text('View details'),
          ),
          onTap: onTap,
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.favorite_border, color: Colors.pink),
            title: Text('Save to favorites'),
          ),
          onTap: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context, ref),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Hero(
                tag: exercise.exerciseId,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.surface,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: exercise.gifUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.fitness_center, color: AppColors.textSecondaryLight),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        CategoryTag(label: exercise.targetMuscle, color: AppColors.primary),
                        CategoryTag(label: exercise.equipment, color: AppColors.accent),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
  }
}

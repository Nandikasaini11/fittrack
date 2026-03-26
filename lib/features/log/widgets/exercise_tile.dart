import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/workout_entry.dart';
import '../../../core/constants/app_colors.dart';

class ExerciseTile extends StatefulWidget {
  final WorkoutEntry entry;
  final VoidCallback onDelete;
  final int index;

  const ExerciseTile({
    super.key,
    required this.entry,
    required this.onDelete,
    this.index = 0,
  });

  @override
  State<ExerciseTile> createState() => _ExerciseTileState();
}

class _ExerciseTileState extends State<ExerciseTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double width) {
    if (_dragOffset < -100) {
      widget.onDelete();
    }
    _offsetAnimation = Tween<Offset>(
      begin: Offset(_dragOffset / width, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    
    _controller.forward(from: 0);
    _dragOffset = 0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, width),
          child: Stack(
            children: [
              if (_dragOffset != 0)
                Positioned.fill(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: _dragOffset < 0 ? AppColors.error : Colors.green,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: _dragOffset < 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Icon(
                          _dragOffset < 0 ? Icons.delete_outline : Icons.check_circle_outline,
                          color: Colors.white,
                          size: (_dragOffset.abs() / 20).clamp(0, 32).toDouble(),
                        ),
                      ],
                    ),
                  ),
                ),
              
              Transform.translate(
                offset: Offset(_dragOffset, 0),
                child: AnimatedBuilder(
                  animation: _offsetAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_offsetAnimation.value.dx * width, 0),
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 24),
                            ),
                            title: Text(
                              widget.entry.exerciseName,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                            subtitle: Text(
                              '${widget.entry.sets} SETS • ${widget.entry.reps} REPS',
                              style: const TextStyle(
                                color: AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                            trailing: widget.entry.weightKg != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: AppColors.primaryGradient),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${widget.entry.weightKg} kg',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

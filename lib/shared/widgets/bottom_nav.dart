import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with SingleTickerProviderStateMixin {
  // UPGRADED: Custom AnimationController for the spring indicator
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    // UPGRADED: ElasticOut curve for that signature "springy" CRED feel
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward(from: 1.0);
  }

  @override
  void didUpdateWidget(BottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      _BottomNavItem(Icons.home_outlined, Icons.home, AppStrings.home, 0),
      _BottomNavItem(Icons.edit_note_outlined, Icons.edit_note, AppStrings.log, 1),
      _BottomNavItem(Icons.bar_chart_outlined, Icons.bar_chart, AppStrings.progress, 2),
      _BottomNavItem(Icons.library_books_outlined, Icons.library_books, AppStrings.library, 3),
      _BottomNavItem(Icons.settings_outlined, Icons.settings, AppStrings.settings, 4),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isSelected = widget.currentIndex == item.index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onTap(item.index),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // UPGRADED: Animated Indicator with scale and fade
                      if (isSelected)
                        ScaleTransition(
                          scale: _animation,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? AppColors.primary : theme.hintColor,
                            size: 26,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected ? AppColors.primary : theme.hintColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  _BottomNavItem(this.icon, this.activeIcon, this.label, this.index);
}

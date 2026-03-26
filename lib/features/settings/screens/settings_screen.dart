import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

import 'dart:ui';
import 'package:flutter/services.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (state) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SETTINGS',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                ).animate().fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 32),
                
                _GlassSettingsGroup(
                  title: 'APPEARANCE',
                  children: [
                    _SettingsToggle(
                      title: 'Dark Mode',
                      subtitle: 'Premium Pitch Black Theme',
                      value: state.isDarkMode,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        ref.read(settingsNotifierProvider.notifier).toggleDarkMode(val);
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 24),
                
                _GlassSettingsGroup(
                  title: 'NOTIFICATIONS',
                  children: [
                    _SettingsToggle(
                      title: 'Work-out Reminders',
                      subtitle: 'Stay on course with daily pings',
                      value: state.isReminderEnabled,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        ref.read(settingsNotifierProvider.notifier).toggleReminder(val);
                      },
                    ),
                    if (state.isReminderEnabled) ...[
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Reminder Time', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        subtitle: Text(state.reminderTime ?? 'Not set', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                        trailing: const Icon(Icons.access_time_rounded, color: AppColors.primary),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            ref.read(settingsNotifierProvider.notifier).setReminderTime(time);
                          }
                        },
                      ),
                    ],
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 24),
                
                _GlassSettingsGroup(
                  title: 'SYSTEM',
                  children: [
                    const _SettingsItem(
                      title: 'Version',
                      trailing: Text('1.2.0-PRO', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ),
                    const Divider(height: 1),
                    _SettingsItem(
                      title: 'Clear Cache',
                      onTap: () => HapticFeedback.heavyImpact(),
                      trailing: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 48),
                Center(
                  child: Text(
                    'DESIGNED FOR ELITES',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight.withOpacity(0.5),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      fontSize: 10,
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _GlassSettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 10,
            ),
          ),
        ),
        // UPGRADED: Glassmorphism Container
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
            ],
          ),
        ),
        // UPGRADED: Custom Styled Switch
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsItem({required this.title, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            trailing,
          ],
        ),
      ),
    );
  }
}

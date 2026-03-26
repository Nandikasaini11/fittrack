import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/notification_service.dart';

part 'settings_provider.g.dart';

@immutable
class SettingsState {
  final bool isDarkMode;
  final bool isReminderEnabled;
  final String? reminderTime;

  const SettingsState({
    required this.isDarkMode,
    required this.isReminderEnabled,
    this.reminderTime,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isReminderEnabled,
    String? reminderTime,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late final StorageService _storage;
  late final NotificationService _notifications;

  @override
  Future<SettingsState> build() async {
    _storage = StorageService();
    _notifications = NotificationService();
    
    return SettingsState(
      isDarkMode: _storage.getDarkMode(),
      isReminderEnabled: _storage.getReminderEnabled(),
      reminderTime: _storage.getReminderTime(),
    );
  }

  Future<void> toggleDarkMode(bool value) async {
    await _storage.setDarkMode(value);
    state = AsyncData(state.value!.copyWith(isDarkMode: value));
  }

  Future<void> toggleReminder(bool value) async {
    await _storage.setReminderEnabled(value);
    if (!value) await _notifications.cancelAll();
    state = AsyncData(state.value!.copyWith(isReminderEnabled: value));
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await _storage.setReminderTime(timeString);
    if (state.value!.isReminderEnabled) await _notifications.scheduleDaily(time);
    state = AsyncData(state.value!.copyWith(reminderTime: timeString));
  }
}

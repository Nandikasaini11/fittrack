import 'package:hive_flutter/hive_flutter.dart';
import '../../features/log/models/workout_entry.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String workoutBoxName = 'workouts';
  static const String settingsBoxName = 'settings';

  late Box<WorkoutEntry> workoutBox;
  late Box settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WorkoutEntryAdapter());
    }
    workoutBox = await Hive.openBox<WorkoutEntry>(workoutBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
  }

  // UPGRADED: Consistent naming with Repository
  List<WorkoutEntry> getWorkoutEntries() => workoutBox.values.toList();
  
  Future<void> addWorkoutEntry(WorkoutEntry entry) async => await workoutBox.put(entry.id, entry);
  
  Future<void> deleteWorkoutEntry(String id) async => await workoutBox.delete(id);

  // UPGRADED: Streak Calculation Logic
  int calculateStreak() {
    final entries = getWorkoutEntries();
    if (entries.isEmpty) return 0;

    // Unique dates with workouts, sorted descending
    final dates = entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    // If no workout today, check if there was one yesterday to continue the streak
    if (dates.isEmpty || (dates.first.isBefore(checkDate) && dates.first.isBefore(checkDate.subtract(const Duration(days: 1))))) {
      return 0;
    }

    for (final date in dates) {
      if (date == checkDate || date == checkDate.subtract(const Duration(days: 1))) {
        streak++;
        checkDate = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // Settings
  bool getDarkMode() => settingsBox.get('darkMode', defaultValue: false);
  Future<void> setDarkMode(bool value) async => await settingsBox.put('darkMode', value);

  bool getReminderEnabled() => settingsBox.get('reminderEnabled', defaultValue: false);
  Future<void> setReminderEnabled(bool value) async => await settingsBox.put('reminderEnabled', value);

  String? getReminderTime() => settingsBox.get('reminderTime');
  Future<void> setReminderTime(String value) async => await settingsBox.put('reminderTime', value);
}

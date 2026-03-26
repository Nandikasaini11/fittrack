# FitTrack

A Flutter workout logger built with clean architecture and a focus on UI quality. Tracks workouts, shows progress over time, and pulls from a real exercise database.

---

## What it does

- **Log workouts** — add exercises with sets, reps, and weight. Autocomplete pulls from the ExerciseDB library or you can type your own.
- **Track progress** — weekly volume chart and a consistency heatmap so you can see your actual habits, not just how you feel about them.
- **Exercise library** — searchable database from ExerciseDB with GIF demos and instructions. Infinite scroll, debounced fuzzy search.
- **Home screen stats** — current streak, total volume, all-time log count. All reactive, updates the moment you log.
- **Reminders** — set a daily workout reminder at whatever time you want. Persists across restarts.
- **Dark mode** — toggleable, saved to local storage.

---

## Stack

| Area | Tech |
|---|---|
| Framework | Flutter + Dart |
| State | Riverpod 2.0 with AsyncNotifier |
| Storage | Hive |
| Networking | Dio with custom interceptors |
| Charts | fl_chart |
| Animations | Lottie, custom CurvedAnimation |
| API | ExerciseDB (no key required) |

---

## Architecture

Feature-first folder structure. Data logic lives in `WorkoutRepository` and `ExerciseRepository` — completely separate from UI. Providers handle loading, error, and data states via `AsyncNotifier`.

```
lib/
  core/           # theme, constants
  features/
    home/         # streak, stats
    log/          # workout logging
    progress/     # charts, heatmap
    library/      # exercise search
    settings/     # theme, notifications
  shared/         # widgets, services
```

---

## Running locally

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Works on iOS, Android, and macOS.

---

## A few things worth noting

The swipe animation on `ExerciseTile` uses `LayoutBuilder` constraints instead of getting size during build — fixed a runtime exception that crashes a lot of Flutter list implementations. The pagination uses offset-based loading so the exercise library handles large datasets without choking. Shimmer skeletons on all list loads so there's no blank flash while data comes in.

---

Built by [Nandika Saini](https://github.com/Nandikasaini11)
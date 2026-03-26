// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workoutRepositoryHash() => r'3f7c7f5e1e1b6928e3df4894779855ff591a1e5f';

/// See also [workoutRepository].
@ProviderFor(workoutRepository)
final workoutRepositoryProvider =
    AutoDisposeProvider<WorkoutRepository>.internal(
  workoutRepository,
  name: r'workoutRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workoutRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WorkoutRepositoryRef = AutoDisposeProviderRef<WorkoutRepository>;
String _$workoutNotifierHash() => r'ebd8e98ca18fb36e2a67d584e83c3ea3c30ad3c7';

/// See also [WorkoutNotifier].
@ProviderFor(WorkoutNotifier)
final workoutNotifierProvider = AutoDisposeAsyncNotifierProvider<
    WorkoutNotifier, List<WorkoutEntry>>.internal(
  WorkoutNotifier.new,
  name: r'workoutNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workoutNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WorkoutNotifier = AutoDisposeAsyncNotifier<List<WorkoutEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

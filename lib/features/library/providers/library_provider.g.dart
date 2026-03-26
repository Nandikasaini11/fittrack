// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$exerciseRepositoryHash() =>
    r'e8468f7ffe421d26f8667fb19eb4393f78fdd28c';

/// See also [exerciseRepository].
@ProviderFor(exerciseRepository)
final exerciseRepositoryProvider =
    AutoDisposeProvider<ExerciseRepository>.internal(
  exerciseRepository,
  name: r'exerciseRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exerciseRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ExerciseRepositoryRef = AutoDisposeProviderRef<ExerciseRepository>;
String _$libraryNotifierHash() => r'62cb9593572ac8d802ac18212c8c3671e2f35823';

/// See also [LibraryNotifier].
@ProviderFor(LibraryNotifier)
final libraryNotifierProvider =
    AutoDisposeAsyncNotifierProvider<LibraryNotifier, List<Exercise>>.internal(
  LibraryNotifier.new,
  name: r'libraryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LibraryNotifier = AutoDisposeAsyncNotifier<List<Exercise>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

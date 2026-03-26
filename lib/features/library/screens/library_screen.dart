import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_provider.dart';
import '../widgets/exercise_card.dart';
import 'package:fittrack/shared/widgets/loading_widget.dart';
import 'package:fittrack/shared/widgets/error_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fittrack/shared/widgets/category_tag.dart';
import '../../../core/constants/app_colors.dart';
import '../models/exercise_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/library_shimmer.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(libraryNotifierProvider.notifier).fetchNextPage();
    }
  }

  void _onSearch(String query) {
    ref.read(libraryNotifierProvider.notifier).search(query);
  }

  void _showDetails(BuildContext context, Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: exercise.exerciseId,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CachedNetworkImage(
                          imageUrl: exercise.gifUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      exercise.name.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CategoryTag(label: exercise.targetMuscle, color: AppColors.primary),
                        const SizedBox(width: 8),
                        CategoryTag(label: exercise.equipment, color: AppColors.accent),
                      ],
                    ),
                    const Divider(height: 48),
                    Text(
                      'INSTRUCTIONS',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...exercise.instructions.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                                child: Text('${e.key + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: Text(e.value, style: const TextStyle(height: 1.5, fontSize: 15))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'EXERCISE LIBRARY',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                  ).animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onChanged: (val) {
                      if (val.isEmpty) _onSearch('');
                    },
                    onSubmitted: _onSearch,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: state.when(
                data: (exercises) => exercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text('No exercises found', style: TextStyle(color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: exercises.length + (state.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < exercises.length) {
                            return ExerciseCard(
                              exercise: exercises[index],
                              onTap: () => _showDetails(context, exercises[index]),
                              index: index,
                            );
                          } else {
                            // UPGRADED: Shimmer loading more indicator
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                        },
                      ),
                // UPGRADED: LibraryShimmer for initial load
                loading: () => _searchController.text.isEmpty && !state.hasValue
                    ? const LibraryShimmer() 
                    : const SizedBox.shrink(),
                error: (err, stack) => ErrorWidgetFit(
                  message: err.toString(),
                  onRetry: () => ref.read(libraryNotifierProvider.notifier).search(_searchController.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

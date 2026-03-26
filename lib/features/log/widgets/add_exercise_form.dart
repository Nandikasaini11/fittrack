import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_provider.dart';
import '../../library/providers/library_provider.dart';
import '../../../core/constants/app_colors.dart';

class AddExerciseForm extends ConsumerStatefulWidget {
  final VoidCallback? onSubmitted;

  const AddExerciseForm({super.key, this.onSubmitted});

  @override
  ConsumerState<AddExerciseForm> createState() => _AddExerciseFormState();
}

class _AddExerciseFormState extends ConsumerState<AddExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // UPGRADED: Trigger suggestions as soon as the field is focused
    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus && _nameController.text.isEmpty) {
        // This triggers the optionsBuilder to run
        _nameController.text = ''; 
      }
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(workoutNotifierProvider.notifier).addEntry(
            name: _nameController.text,
            sets: int.parse(_setsController.text),
            reps: int.parse(_repsController.text),
            weight: double.tryParse(_weightController.text),
          );
      
      widget.onSubmitted?.call();
      
      _nameController.clear();
      _setsController.clear();
      _repsController.clear();
      _weightController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // UPGRADED: Handle for DraggableScrollableSheet
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'NEW WORKOUT',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 24),
            
            // UPGRADED: RawAutocomplete for library integration
            RawAutocomplete<String>(
              textEditingController: _nameController,
              focusNode: _nameFocusNode,
              optionsBuilder: (TextEditingValue textEditingValue) async {
                final exercises = await ref.read(exerciseRepositoryProvider).getExercises(limit: 50);
                if (textEditingValue.text.isEmpty) {
                  return exercises.take(10).map((e) => e.name);
                }
                return exercises
                    .where((e) => e.name.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                    .map((e) => e.name);
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Exercise Name',
                    prefixIcon: const Icon(Icons.fitness_center),
                    suffixIcon: InkWell(
                      onTap: () {
                        focusNode.requestFocus();
                        // Trigger options by ensuring the text triggers a change
                        final current = controller.text;
                        controller.text = ' '; 
                        controller.text = current;
                      },
                      child: const Icon(Icons.arrow_drop_down_circle_outlined, size: 22, color: AppColors.primary),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
                  onFieldSubmitted: (val) => onFieldSubmitted(),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                if (options.isEmpty) return const SizedBox.shrink();

                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 48),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 250),
                            width: MediaQuery.of(context).size.width - 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (context, index) => Divider(
                                color: AppColors.primary.withOpacity(0.05),
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  title: Text(
                                    option,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  onTap: () => onSelected(option),
                                  hoverColor: AppColors.primary.withOpacity(0.05),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setsController,
                    decoration: InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? '!' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _repsController,
                    decoration: InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? '!' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('LOG WORKOUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

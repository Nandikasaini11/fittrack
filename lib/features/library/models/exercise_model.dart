class Exercise {
  final String exerciseId;
  final String name;
  final List<String> targetMuscles;
  final List<String> equipments;
  final List<String> bodyParts;
  final String gifUrl;
  final List<String> instructions;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.targetMuscles,
    required this.equipments,
    required this.bodyParts,
    required this.gifUrl,
    required this.instructions,
  });

  // Helper for UI consistency (taking the first item if needed)
  String get targetMuscle => targetMuscles.isNotEmpty ? targetMuscles.first : 'Unknown';
  String get equipment => equipments.isNotEmpty ? equipments.first : 'Unknown';

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      targetMuscles: (json['targetMuscles'] as List).map((e) => e as String).toList(),
      equipments: (json['equipments'] as List).map((e) => e as String).toList(),
      bodyParts: (json['bodyParts'] as List).map((e) => e as String).toList(),
      gifUrl: json['gifUrl'] as String,
      instructions: (json['instructions'] as List).map((e) => e as String).toList(),
    );
  }
}

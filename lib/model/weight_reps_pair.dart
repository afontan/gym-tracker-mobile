class WeightRepsPair {
  final int? id;
  final int exerciseSessionId;
  final int repetitions;
  final double weight;

  WeightRepsPair({
    this.id,
    required this.exerciseSessionId,
    required this.repetitions,
    required this.weight,
  });

  factory WeightRepsPair.fromJson(Map<String, dynamic> json) {
    return WeightRepsPair(
      id: json['id'] ?? 0,
      exerciseSessionId: json['exerciseSessionId'],
      repetitions: json['repetitions'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseSessionId': exerciseSessionId,
      'repetitions': repetitions,
      'weight': weight,
    };
  }
}

import 'weight_reps_pair.dart';

class ExerciseSession {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final String? exerciseName;
  final List<WeightRepsPair> weightRepsPairs;

  ExerciseSession({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    this.exerciseName,
    required this.weightRepsPairs,
  });

  factory ExerciseSession.fromJson(Map<String, dynamic> json, {List<WeightRepsPair>? weightRepsPairs}) {
    return ExerciseSession(
      id: json['id'],
      sessionId: json['sessionId'],
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      weightRepsPairs: weightRepsPairs ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      'sessionId': sessionId,
      'exerciseName': exerciseName,
      'exerciseId': exerciseId,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}

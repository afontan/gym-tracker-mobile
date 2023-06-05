// exercise.dart
class Exercise {
  final int? id;
  final String name;
  final int? lastWeight;
  final String imageUrl;

  Exercise({this.id, this.lastWeight, required this.name, required this.imageUrl});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      lastWeight: json['lastWeight'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastWeight': lastWeight,
      'imageUrl': imageUrl,
    };
  }
}


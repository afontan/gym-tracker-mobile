class Session {
  final int? id;
  final String date;

  Session({this.id, required this.date});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
    };
  }
}

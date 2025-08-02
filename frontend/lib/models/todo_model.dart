class Todo {
  final int id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime date;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.date,
  });

  /// Convert JSON → Todo object
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isDone: json['isDone'] ?? false,
      date: DateTime.parse(json['date']),
    );
  }

  /// Convert Todo object → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'date': date.toIso8601String(),
    };
  }
}

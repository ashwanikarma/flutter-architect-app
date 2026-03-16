/// Data model for Task entity, maps to/from JSON.
class TaskModel {
  final String? id;
  final String title;
  final String description;
  final DateTime createdDate;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.createdDate,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}

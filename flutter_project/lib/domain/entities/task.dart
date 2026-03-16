/// Domain entity for Task – framework-agnostic.
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  Task({required this.id, required this.title, required this.description, required this.createdAt});
}

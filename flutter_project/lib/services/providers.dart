import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../data/models/task_model.dart';

/// Global API service provider.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Async provider that fetches tasks from the API.
/// Falls back to demo data when the backend is unreachable.
final tasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final response = await api.getTasks();
    final list = response.data as List;
    return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  } catch (_) {
    // Demo data when API is unavailable
    return [
      TaskModel(id: '1', title: 'Sunrise Jogging', description: '07.00 - 07.30', createdDate: DateTime.now()),
      TaskModel(id: '2', title: 'Healthy Breakfast', description: '07.30 - 07.45', createdDate: DateTime.now()),
      TaskModel(id: '3', title: 'Strength Training', description: '07.45 - 08.00', createdDate: DateTime.now()),
      TaskModel(id: '4', title: 'Core Workout', description: '09.00 - 09.50', createdDate: DateTime.now()),
      TaskModel(id: '5', title: 'Smoothie Prep', description: '09.50 - 10.00', createdDate: DateTime.now()),
    ];
  }
});

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';

/// Centralized API service using Dio.
/// Automatically attaches the JWT token from secure storage.
class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  // ── Auth ──────────────────────────────────────────

  Future<Response> login(String email, String password) async {
    return _dio.post(ApiConstants.login, data: {'email': email, 'password': password});
  }

  Future<Response> register(String email, String password) async {
    return _dio.post(ApiConstants.register, data: {'email': email, 'password': password});
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }

  // ── Tasks CRUD ────────────────────────────────────

  Future<Response> getTasks() => _dio.get(ApiConstants.tasks);

  Future<Response> createTask(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.tasks, data: data);

  Future<Response> updateTask(String id, Map<String, dynamic> data) =>
      _dio.put('${ApiConstants.tasks}/$id', data: data);

  Future<Response> deleteTask(String id) =>
      _dio.delete('${ApiConstants.tasks}/$id');
}

/// API configuration constants.
/// Change [baseUrl] to point to your .NET 8 backend.
class ApiConstants {
  static const String baseUrl = 'http://localhost:5000/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Tasks
  static const String tasks = '/tasks';
}

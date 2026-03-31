// ============================================================================
// api_service.dart — Centralized API Service using Dio
// ============================================================================
// WHAT IS AN API SERVICE?
//   Imagine your Flutter app is a customer at a restaurant.
//   The API service is the WAITER — it takes your order (request) to the
//   kitchen (C# backend), waits for the food (data), and brings it back.
//
// WHAT IS DIO?
//   Dio is like a "super-powered delivery service" for HTTP requests.
//   It's similar to Axios in JavaScript or HttpClient in C#.
//   Benefits over Flutter's built-in http package:
//     - Automatic JSON parsing
//     - Interceptors (auto-attach auth tokens to every request)
//     - Timeout handling (don't wait forever if the server is down)
//     - Better error messages
//
// WHAT IS AN INTERCEPTOR?
//   Think of it as a "security checkpoint" that every request passes through.
//   Before any request leaves the app, the interceptor automatically attaches
//   the user's authentication token (like showing your ID badge at a door).
//
// BASE URL:
//   This is the "address" of your C# backend server.
//   During development, it's usually localhost (your own computer).
//   In production, it would be something like "https://api.yourcompany.com"
// ============================================================================

import 'package:dio/dio.dart';
import '../models/policy_model.dart';

class ApiService {
  // ── The Dio instance — our HTTP client ──
  // Think of this as the "delivery truck" that carries requests back and forth.
  final Dio _dio;

  /// Constructor — sets up Dio with default configuration.
  ///
  /// BaseOptions = the "default settings" for every request:
  ///   - baseUrl: Where to send requests (your C# server address)
  ///   - connectTimeout: How long to wait for a connection (10 seconds)
  ///   - receiveTimeout: How long to wait for a response (10 seconds)
  ///   - headers: What format we're sending/expecting (JSON)
  ApiService()
      : _dio = Dio(BaseOptions(
          // ────────────────────────────────────────────────────────────
          // 🔧 CHANGE THIS to your C# backend URL!
          // For Android emulator: use 10.0.2.2 instead of localhost
          // For iOS simulator: use localhost or 127.0.0.1
          // For real device: use your computer's IP address (e.g., 192.168.1.100)
          // ────────────────────────────────────────────────────────────
          baseUrl: 'http://localhost:5000/api',

          // Timeout settings — don't wait forever!
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),

          // Tell the server we're sending and expecting JSON data
          headers: {'Content-Type': 'application/json'},
        ));

  // ═══════════════════════════════════════════════════════════════════
  // CRUD OPERATIONS — The 4 basic data operations
  // ═══════════════════════════════════════════════════════════════════
  //
  // HTTP Methods explained:
  //   GET    = "Give me data"     (READ)
  //   POST   = "Save this new data" (CREATE)
  //   PUT    = "Update this data"   (UPDATE)
  //   DELETE = "Remove this data"   (DELETE)
  //
  // Each method returns a Response object containing:
  //   - response.data: The actual data from the server
  //   - response.statusCode: 200 = OK, 404 = Not found, 500 = Server error
  // ═══════════════════════════════════════════════════════════════════

  // ── CREATE (POST) ──────────────────────────────────────────────────
  /// Creates a new policy on the server.
  ///
  /// ANALOGY: Like filling out a new form and handing it to the receptionist.
  /// The receptionist (server) files it and gives you back a copy with
  /// a new ID number stamped on it.
  ///
  /// [policy] — The PolicyModel object to create
  /// Returns: The created policy (now with an ID from the server)
  Future<PolicyModel> createPolicy(PolicyModel policy) async {
    try {
      // _dio.post sends a POST request to "/policies" endpoint
      // policy.toJson() converts our Dart object to JSON format
      final response = await _dio.post(
        '/policies',
        data: policy.toJson(),
      );
      // Convert the server's JSON response back to a PolicyModel
      return PolicyModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // If something goes wrong, throw a user-friendly error
      throw _handleError(e);
    }
  }

  // ── READ (GET) ─────────────────────────────────────────────────────
  /// Fetches ALL policies from the server.
  ///
  /// ANALOGY: Like asking the receptionist "Show me all the files in the cabinet."
  /// They hand you a stack of folders — each folder is one policy.
  ///
  /// Returns: A list of PolicyModel objects
  Future<List<PolicyModel>> getPolicies() async {
    try {
      // _dio.get sends a GET request — no body needed, just asking for data
      final response = await _dio.get('/policies');

      // The server returns a JSON array like: [{...}, {...}, {...}]
      // We convert each item in the array to a PolicyModel object
      final list = response.data as List;
      return list
          .map((item) => PolicyModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetches ONE specific policy by its ID.
  ///
  /// ANALOGY: Like asking "Show me file number ABC123 please."
  ///
  /// [id] — The unique ID of the policy to fetch
  Future<PolicyModel> getPolicyById(String id) async {
    try {
      final response = await _dio.get('/policies/$id');
      return PolicyModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── UPDATE (PUT) ───────────────────────────────────────────────────
  /// Updates an existing policy on the server.
  ///
  /// ANALOGY: Like taking a form back to the receptionist and saying
  /// "I need to correct some information on file ABC123."
  /// They update the file and hand you back the corrected version.
  ///
  /// [id] — Which policy to update
  /// [policy] — The updated data
  Future<PolicyModel> updatePolicy(String id, PolicyModel policy) async {
    try {
      final response = await _dio.put(
        '/policies/$id',
        data: policy.toJson(),
      );
      return PolicyModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────
  /// Deletes a policy from the server.
  ///
  /// ANALOGY: Like telling the receptionist "Please shred file ABC123."
  /// Once deleted, it's gone forever (unless you have backups!).
  ///
  /// [id] — Which policy to delete
  Future<void> deletePolicy(String id) async {
    try {
      await _dio.delete('/policies/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ═══════════════════════════════════════════════════════════════════
  //
  // When something goes wrong (server down, no internet, wrong URL),
  // Dio throws a DioException. This method converts those technical
  // errors into human-readable messages.

  /// Converts Dio errors into user-friendly error messages.
  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Is the server running?';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.badResponse:
        // The server responded but with an error code
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Unknown error';
        return 'Server error ($statusCode): $message';
      case DioExceptionType.connectionError:
        return 'Cannot connect to server. Check your internet connection.';
      default:
        return 'Something went wrong: ${e.message}';
    }
  }
}

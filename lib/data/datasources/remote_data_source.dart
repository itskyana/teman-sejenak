import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

/// Remote data source for API calls
/// 
/// This class handles all HTTP requests to the backend API.
/// It provides a clean interface for making API calls with proper
/// error handling and response parsing.
class RemoteDataSource {
  RemoteDataSource._();
  static final RemoteDataSource instance = RemoteDataSource._();

  final String _baseUrl = AppConstants.baseUrl;

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
    T Function(List<dynamic>)? fromJsonList,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await http
          .get(uri, headers: _buildHeaders(headers))
          .timeout(AppConstants.connectionTimeout);

      return _handleResponse(response, fromJson, fromJsonList);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.connectionTimeout);

      return _handleResponse(response, fromJson, null);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.connectionTimeout);

      return _handleResponse(response, fromJson, null);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(AppConstants.connectionTimeout);

      return _handleResponse(response, fromJson, null);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return uri;
  }

  Map<String, String> _buildHeaders(Map<String, String>? extra) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
    T Function(List<dynamic>)? fromJsonList,
  ) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success response
      if (body is Map<String, dynamic>) {
        // Handle wrapped response (e.g., { "status": 200, "data": {...} })
        final data = body['data'] ?? body;
        
        if (fromJson != null && data is Map<String, dynamic>) {
          return ApiResponse.success(fromJson(data));
        }
        if (fromJsonList != null && data is List) {
          return ApiResponse.success(fromJsonList(data));
        }
        return ApiResponse.success(data as T);
      }
      if (body is List && fromJsonList != null) {
        return ApiResponse.success(fromJsonList(body));
      }
      return ApiResponse.success(body as T);
    } else {
      // Error response
      final message = body['message'] ?? 'Unknown error occurred';
      return ApiResponse.error(message, statusCode: response.statusCode);
    }
  }

  String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    }
    if (error is http.ClientException) {
      return 'Terjadi kesalahan koneksi. Silakan coba lagi.';
    }
    if (error is FormatException) {
      return 'Format respons tidak valid.';
    }
    return error.toString();
  }
}

/// API Response wrapper
/// 
/// Provides a clean way to handle API responses with success/error states.
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;

  ApiResponse._({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse._(data: data, isSuccess: true);
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse._(
      error: message,
      statusCode: statusCode,
      isSuccess: false,
    );
  }

  /// Execute callback based on response state
  R when<R>({
    required R Function(T data) success,
    required R Function(String error) failure,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    }
    return failure(error ?? 'Unknown error');
  }
}

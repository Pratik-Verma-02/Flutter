import 'package:dio/dio.dart';
import 'package:agent_prompt/core/constants/app_constants.dart';
import 'package:agent_prompt/models/prompt_request_model.dart';
import 'package:agent_prompt/services/auth_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiService {
  late final Dio _dio;
  final AuthService _authService;

  ApiService(this._authService) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authService.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        final response = error.response;
        if (response != null) {
          final data = response.data;
          final message = data is Map ? data['error'] ?? data['message'] ?? 'Request failed' : 'Request failed';
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiException(message.toString(), statusCode: response.statusCode),
              response: response,
              type: error.type,
            ),
          );
        } else {
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiException('Network error. Please check your connection.'),
              type: error.type,
            ),
          );
        }
      },
    ));
  }

  Future<Map<String, dynamic>> generatePrompt(PromptRequestModel request) async {
    try {
      final response = await _dio.post(
        '/api/prompts/generate',
        data: request.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to generate prompt');
    }
  }

  Future<Map<String, dynamic>> editPrompt(
    String promptId,
    String modifications,
  ) async {
    try {
      final response = await _dio.post(
        '/api/prompts/$promptId/edit',
        data: {'modifications': modifications},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to edit prompt');
    }
  }

  Future<Map<String, dynamic>> enhancePrompt(
    String promptId,
    String additionalRequirements,
  ) async {
    try {
      final response = await _dio.post(
        '/api/prompts/$promptId/enhance',
        data: {'additionalRequirements': additionalRequirements},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to enhance prompt');
    }
  }

  Future<Map<String, dynamic>> getUserCredits() async {
    try {
      final response = await _dio.get('/api/user/credits');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to get credits');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/api/user/profile');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to get profile');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/api/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agent_prompt/services/api_service.dart';
import 'package:agent_prompt/providers/auth_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiService(authService);
});

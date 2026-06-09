import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:agent_prompt/models/prompt_model.dart';
import 'package:agent_prompt/models/prompt_request_model.dart';
import 'package:agent_prompt/providers/auth_provider.dart';
import 'package:agent_prompt/providers/user_provider.dart';
import 'package:agent_prompt/services/api_service.dart';
import 'package:agent_prompt/services/firestore_service.dart';

final _uuid = const Uuid();

final apiServiceProvider = Provider<ApiService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiService(authService);
});

final recentPromptsProvider = StreamProvider<List<PromptModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).watchRecentPrompts(user.uid);
});

final promptDetailProvider =
    FutureProvider.family<PromptModel?, String>((ref, promptId) async {
  return ref.watch(firestoreServiceProvider).getPromptById(promptId);
});

class SavedPromptsState {
  final List<PromptModel> prompts;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final String filter; // 'all', 'favorites'
  final String searchQuery;

  const SavedPromptsState({
    this.prompts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.filter = 'all',
    this.searchQuery = '',
  });

  SavedPromptsState copyWith({
    List<PromptModel>? prompts,
    bool? isLoading,
    bool? hasMore,
    String? error,
    String? filter,
    String? searchQuery,
  }) {
    return SavedPromptsState(
      prompts: prompts ?? this.prompts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SavedPromptsNotifier extends Notifier<SavedPromptsState> {
  @override
  SavedPromptsState build() => const SavedPromptsState();

  Future<void> loadPrompts({bool reset = false}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (reset) {
      state = state.copyWith(prompts: [], hasMore: true, isLoading: true, error: null);
    } else {
      if (state.isLoading || !state.hasMore) return;
      state = state.copyWith(isLoading: true);
    }

    try {
      final service = ref.read(firestoreServiceProvider);
      final fetched = await service.getPrompts(
        user.uid,
        favoritesOnly: state.filter == 'favorites',
      );

      final all = reset ? fetched : [...state.prompts, ...fetched];
      state = state.copyWith(
        prompts: all,
        isLoading: false,
        hasMore: fetched.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> search(String query) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = state.copyWith(searchQuery: query, isLoading: true);
    try {
      final service = ref.read(firestoreServiceProvider);
      if (query.isEmpty) {
        await loadPrompts(reset: true);
      } else {
        final results = await service.searchPrompts(user.uid, query);
        state = state.copyWith(prompts: results, isLoading: false, hasMore: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
    loadPrompts(reset: true);
  }

  Future<void> deletePrompt(String promptId) async {
    await ref.read(firestoreServiceProvider).deletePrompt(promptId);
    state = state.copyWith(
      prompts: state.prompts.where((p) => p.promptId != promptId).toList(),
    );
  }

  Future<void> toggleFavorite(String promptId) async {
    final idx = state.prompts.indexWhere((p) => p.promptId == promptId);
    if (idx == -1) return;
    final current = state.prompts[idx].isFavorite;
    await ref.read(firestoreServiceProvider).toggleFavorite(promptId, !current);
    final updated = List<PromptModel>.from(state.prompts);
    updated[idx] = updated[idx].copyWith(isFavorite: !current);
    state = state.copyWith(prompts: updated);
  }
}

final savedPromptsNotifierProvider =
    NotifierProvider<SavedPromptsNotifier, SavedPromptsState>(
  SavedPromptsNotifier.new,
);

class PromptGenerationNotifier extends Notifier<AsyncValue<PromptModel?>> {
  @override
  AsyncValue<PromptModel?> build() => const AsyncValue.data(null);

  Future<PromptModel?> generate(PromptRequestModel request) async {
    state = const AsyncValue.loading();
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.generatePrompt(request);

      final promptId = response['promptId'] as String? ?? _uuid.v4();
      final content = response['content'] as String? ?? '';
      final title = response['title'] as String? ??
          '${request.projectType}: ${request.appName}';

      final user = ref.read(currentUserProvider);
      final prompt = PromptModel(
        promptId: promptId,
        uid: user?.uid ?? '',
        title: title,
        projectType: request.projectType,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        appName: request.appName,
        packageName: request.packageName,
      );

      await ref.read(firestoreServiceProvider).savePrompt(prompt);

      state = AsyncValue.data(prompt);
      return prompt;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final promptGenerationProvider =
    NotifierProvider<PromptGenerationNotifier, AsyncValue<PromptModel?>>(
  PromptGenerationNotifier.new,
);

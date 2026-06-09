import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agent_prompt/models/user_model.dart';
import 'package:agent_prompt/providers/auth_provider.dart';
import 'package:agent_prompt/services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  final service = ref.watch(firestoreServiceProvider);
  return service.watchUserProfile(user.uid);
});

final creditsProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(userProfileProvider).whenData((user) => user?.credits ?? 0);
});

class UserProfileNotifier extends Notifier<AsyncValue<UserModel?>> {
  @override
  AsyncValue<UserModel?> build() {
    final profile = ref.watch(userProfileProvider);
    return profile;
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final service = ref.read(firestoreServiceProvider);
    state = const AsyncValue.loading();
    try {
      final profile = await service.getUserProfile(user.uid);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await ref.read(firestoreServiceProvider).updateUserProfile(user.uid, data);
  }
}

final userProfileNotifierProvider =
    NotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>(
  UserProfileNotifier.new,
);

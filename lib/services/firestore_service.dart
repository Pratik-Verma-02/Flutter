import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agent_prompt/models/user_model.dart';
import 'package:agent_prompt/models/prompt_model.dart';
import 'package:agent_prompt/core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection('users');
  CollectionReference get _prompts => _db.collection('prompts');
  CollectionReference get _usage => _db.collection('usage');

  // ─── User ──────────────────────────────────────────────────────
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  // ─── Prompts ───────────────────────────────────────────────────
  Future<List<PromptModel>> getPrompts(
    String uid, {
    DocumentSnapshot? lastDoc,
    int limit = AppConstants.promptsPageSize,
    bool favoritesOnly = false,
  }) async {
    Query query = _prompts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (favoritesOnly) {
      query = query.where('isFavorite', isEqualTo: true);
    }

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PromptModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<PromptModel>> watchRecentPrompts(String uid, {int limit = 5}) {
    return _prompts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromptModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<PromptModel?> getPromptById(String promptId) async {
    final doc = await _prompts.doc(promptId).get();
    if (!doc.exists) return null;
    return PromptModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<String> savePrompt(PromptModel prompt) async {
    final docRef = _prompts.doc(prompt.promptId.isNotEmpty ? prompt.promptId : null);
    await docRef.set(prompt.toJson());
    return docRef.id;
  }

  Future<void> updatePrompt(String promptId, Map<String, dynamic> data) async {
    await _prompts.doc(promptId).update({
      ...data,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deletePrompt(String promptId) async {
    await _prompts.doc(promptId).delete();
  }

  Future<void> toggleFavorite(String promptId, bool isFavorite) async {
    await _prompts.doc(promptId).update({'isFavorite': isFavorite});
  }

  Future<List<PromptModel>> searchPrompts(String uid, String query) async {
    final snapshot = await _prompts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) => PromptModel.fromJson(doc.data() as Map<String, dynamic>))
        .where((p) =>
            p.title.toLowerCase().contains(lowerQuery) ||
            p.content.toLowerCase().contains(lowerQuery) ||
            p.projectType.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // ─── Usage ─────────────────────────────────────────────────────
  Future<void> logUsage({
    required String uid,
    required String action,
    required int creditsUsed,
  }) async {
    await _usage.add({
      'uid': uid,
      'action': action,
      'creditsUsed': creditsUsed,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });
  }
}

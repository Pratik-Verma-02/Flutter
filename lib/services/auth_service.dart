import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agent_prompt/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());

    await _createUserDocument(
      uid: credential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      photoUrl: null,
    );

    return credential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    final docRef = _firestore.collection('users').doc(userCredential.user!.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await _createUserDocument(
        uid: userCredential.user!.uid,
        name: googleUser.displayName ?? 'User',
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );
    }

    return userCredential;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  Future<void> _createUserDocument({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final userModel = UserModel(
      uid: uid,
      name: name,
      email: email,
      credits: 10,
      lastResetDate: DateTime.now(),
      totalPrompts: 0,
      createdAt: DateTime.now(),
      photoUrl: photoUrl,
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .set(userModel.toJson(), SetOptions(merge: true));
  }
}

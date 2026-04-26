import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  // ─── Email/Password Sign Up ───
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String phoneNumber = '',
    UserRole role = UserRole.citizen,
    String department = '',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);

    final user = AppUser(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      role: role,
      department: department,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  // ─── Email/Password Sign In ───
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Try to get user data from Firestore
      final userData = await getUserData(credential.user!.uid);
      if (userData != null) return userData;

      // If no Firestore doc exists (e.g., old account), create one
      final user = AppUser(
        uid: credential.user!.uid,
        email: email,
        displayName: credential.user!.displayName ?? 'User',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      print('DEBUG: signInWithEmail failed: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('DEBUG: signInWithEmail unexpected error: $e');
      rethrow;
    }
  }

  // ─── Get User Data ───
  Future<AppUser?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // ─── Sign Out ───
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── Reset Password ───
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Seed Admin Account ───
  Future<void> seedAdmin() async {
    const adminEmail = 'care4yourcare.07@gmail.com';
    const adminPassword = 'fixmystreet7';

    try {
      // Check if admin already exists in Firestore
      final existing = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) return; // Admin already exists

      // Try to create admin in Firebase Auth
      UserCredential cred;
      try {
        cred = await _auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Admin auth account exists but no Firestore doc — sign in to get uid
          cred = await _auth.signInWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );
        } else {
          print('DEBUG: seedAdmin Auth check failed: ${e.code} - ${e.message}');
          return; // Some other error, skip silently
        }
      }

      print('DEBUG: seedAdmin Auth success');

      // Create admin profile in Firestore
      final admin = AppUser(
        uid: cred.user!.uid,
        email: adminEmail,
        displayName: 'FixMyStreet Admin',
        role: UserRole.admin,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await _firestore.collection('users').doc(admin.uid).set(admin.toMap());

      // Sign out so the app starts fresh
      await _auth.signOut();
    } catch (e) {
      print('DEBUG: seedAdmin unexpected error: $e');
      // Silently fail — admin seeding is best-effort
    }
  }

  // ─── Get users by role ───
  Future<List<AppUser>> getUsersByRole(UserRole role) async {
    final roleString = AppUser(
      uid: '',
      email: '',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      role: role,
    ).toMap()['role'];

    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: roleString)
        .get();

    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ─── Update User Profile ───
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
  }) async {
    final Map<String, dynamic> updates = {};
    if (displayName != null) updates['displayName'] = displayName;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (photoURL != null) updates['photoURL'] = photoURL;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);

      // Also update Firebase Auth display name if provided
      if (displayName != null && _auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(displayName);
      }
    }
  }

  // ─── Update User Language Preference ───
  Future<void> updateUserLanguage({
    required String uid,
    required String languageCode,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'language': languageCode,
    });
  }
}

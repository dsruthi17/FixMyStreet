import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';
import 'locale_provider.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isOfficer => _currentUser?.isOfficer ?? false;
  bool get isWorker => _currentUser?.isWorker ?? false;
  bool get isCitizen => _currentUser?.isCitizen ?? true;
  UserRole get userRole => _currentUser?.role ?? UserRole.citizen;
  String? get error => _error;

  AppAuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Seed admin account on first launch
      await _authService.seedAdmin();

      final firebaseUser = _authService.currentFirebaseUser;
      if (firebaseUser != null) {
        _currentUser = await _authService.getUserData(firebaseUser.uid);
        notifyListeners();
      }
    } catch (_) {}
  }

  // ─── Email/Password Sign In ───
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      _currentUser = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _setLoading(false);
      return _currentUser != null;
    } catch (e) {
      _error = _getErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ─── Email/Password Sign Up ───
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    String phoneNumber = '',
    UserRole role = UserRole.citizen,
    String department = '',
  }) async {
    _setLoading(true);
    _error = null;
    try {
      _currentUser = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
        role: role,
        department: department,
      );
      _setLoading(false);
      return _currentUser != null;
    } catch (e) {
      _error = _getErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ─── Get workers/officers ───
  Future<List<AppUser>> getWorkers() async {
    return _authService.getUsersByRole(UserRole.worker);
  }

  Future<List<AppUser>> getOfficers() async {
    return _authService.getUsersByRole(UserRole.officer);
  }

  // ─── Sign Out ───
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // ─── Reset Password ───
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ─── Update User Profile ───
  Future<bool> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? photoURL,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _error = null;
    try {
      await _authService.updateUserProfile(
        uid: _currentUser!.uid,
        displayName: displayName,
        phoneNumber: phoneNumber,
        photoURL: photoURL,
      );

      // Refresh user data
      _currentUser = await _authService.getUserData(_currentUser!.uid);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ─── Update User Language ───
  Future<bool> updateLanguage(String languageCode) async {
    if (_currentUser == null) return false;

    try {
      await _authService.updateUserLanguage(
        uid: _currentUser!.uid,
        languageCode: languageCode,
      );

      // Update local user object
      _currentUser = _currentUser!.copyWith(language: languageCode);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ─── Sync User Language with LocaleProvider ───
  void syncLanguageWithLocale(LocaleProvider localeProvider) {
    if (_currentUser != null && _currentUser!.language.isNotEmpty) {
      localeProvider.setLocale(Locale(_currentUser!.language));
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String _getErrorMessage(String error) {
    print('DEBUG: AuthProvider error caught: $error');
    if (error.contains('user-not-found')) {
      return 'No account found. Please register first.';
    }
    if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    }
    if (error.contains('email-already-in-use')) {
      return 'This mobile number or email is already registered. Try logging in instead.';
    }
    if (error.contains('weak-password')) {
      return 'Password is too weak (min 6 characters)';
    }
    if (error.contains('invalid-email')) {
      return 'Invalid email address';
    }
    if (error.contains('invalid-login-credentials') ||
        error.contains('invalid-credential')) {
      return 'Invalid email or password. Please check your credentials.';
    }
    if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }
    if (error.contains('operation-not-allowed')) {
      return 'Email/Password login is not enabled in Firebase Console.';
    }
    return 'Error: ${error.replaceAll(RegExp(r'\[.*?\]'), '').trim()}';
  }
}

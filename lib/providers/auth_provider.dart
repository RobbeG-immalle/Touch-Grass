import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:touch_grass/models/user_model.dart';
import 'package:touch_grass/services/auth_service.dart';
import 'package:touch_grass/services/database_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final bool firebaseAvailable;
  final AuthService _authService = AuthService();
  final DatabaseService _db = DatabaseService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;

  AuthProvider({required this.firebaseAvailable}) {
    if (firebaseAvailable) {
      _authService.authStateChanges.listen(_onAuthChanged);
    } else {
      _status = AuthStatus.unauthenticated;
    }
  }

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } else {
      try {
        _currentUser = await _db.getUser(user.uid);
        _status = AuthStatus.authenticated;
      } catch (_) {
        _status = AuthStatus.authenticated;
      }
    }
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final cred = await _authService.signUp(email: email, password: password);
      final user = UserModel(
        uid: cred.user!.uid,
        username: username,
        email: email,
        createdAt: DateTime.now(),
      );
      await _db.createUser(user);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final cred = await _authService.signInWithGoogle();
      if (cred == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      final existing = await _db.getUser(cred.user!.uid);
      if (existing == null) {
        final user = UserModel(
          uid: cred.user!.uid,
          username: cred.user!.displayName ?? 'Grasser',
          email: cred.user!.email ?? '',
          avatarUrl: cred.user!.photoURL ?? '',
          createdAt: DateTime.now(),
        );
        await _db.createUser(user);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Google sign-in failed. Please try again.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> deleteAccount() async {
    try {
      if (_currentUser != null) {
        await _db.deleteUser(_currentUser!.uid);
      }
      await _authService.deleteAccount();
      return true;
    } catch (_) {
      return false;
    }
  }

  void refreshUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      _currentUser = await _db.getUser(user.uid);
      notifyListeners();
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}

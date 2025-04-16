import 'package:flutter/material.dart';
import 'package:infy/data/class/user_class.dart';
import 'package:infy/data/contants/strings.dart';
import 'package:infy/data/services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class UserProvider with ChangeNotifier {
  // Instances
  final AuthService _authService = AuthService();

  // État de l'utilisateur
  User? _user;
  AuthStatus _status = AuthStatus.unknown;
  bool _loading = true;
  String? _error;

  // Getters
  User? get user => _user;
  AuthStatus get status => _status;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.unauthenticated;

  // Constructeur qui initialise l'état de l'utilisateur
  UserProvider() {
    _initializeUser();
  }

  // Initialiser l'utilisateur en fonction de l'état de l'authentification
  Future<void> _initializeUser() async {
    _loading = true;
    notifyListeners();

    try {
      // Vérifier d'abord les données locales pour une expérience utilisateur plus rapide
      final localUser = await _authService.getUserDataLocally();
      if (localUser != null) {
        _user = localUser;
        _status = AuthStatus.authenticated;
        notifyListeners();
      }

      // Ensuite, vérifier si l'utilisateur est réellement connecté via Firebase
      final currentUser = await _authService.getCurrentUser();

      if (currentUser != null) {
        _user = currentUser;
        _status = AuthStatus.authenticated;

        // Mettre à jour les données locales avec les plus récentes
        await _authService.storeUserDataLocally(currentUser);
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;

        // Effacer les données locales si l'utilisateur n'est pas connecté
        await _authService.clearLocalUserData();
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Se connecter avec email et mot de passe
  Future<void> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;

        // Stocker les données utilisateur localement
        await _authService.storeUserDataLocally(user);
      }
    } catch (e) {
      _error = '${AppStrings.error}: $e';
      _status = AuthStatus.unauthenticated;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Créer un compte avec email et mot de passe
  Future<void> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.createUserWithEmailAndPassword(
        email,
        password,
        firstName,
        lastName,
      );

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;

        // Stocker les données utilisateur localement
        await _authService.storeUserDataLocally(user);
      }
    } catch (e) {
      _error = '${AppStrings.error}: $e';
      _status = AuthStatus.unauthenticated;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Se déconnecter
  Future<void> signOut() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      await _authService.clearLocalUserData();

      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _error = '${AppStrings.errorLogout}: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? photoURL,
    Map<String, dynamic>? additionalInfo,
  }) async {
    if (_user == null) {
      _error = AppStrings.userNotLoggedIn;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        firstName: firstName,
        lastName: lastName,
        photoURL: photoURL,
        additionalInfo: additionalInfo,
        updatedAt: DateTime.now(),
      );

      final result = await _authService.updateUserInfo(updatedUser);

      if (result != null) {
        _user = result;

        // Mettre à jour les données locales
        await _authService.storeUserDataLocally(result);
      }
    } catch (e) {
      _error = '${AppStrings.errorUpdatingProfile}: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _error = '${AppStrings.error}: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Rafraîchir les données utilisateur depuis Firestore
  Future<void> refreshUserData() async {
    if (_user == null) {
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final refreshedUser = await _authService.fetchUserData(_user!.uid);

      if (refreshedUser != null) {
        _user = refreshedUser;

        // Mettre à jour les données locales
        await _authService.storeUserDataLocally(refreshedUser);
      }
    } catch (e) {
      _error = '${AppStrings.error}: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

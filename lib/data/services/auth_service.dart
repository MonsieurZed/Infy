import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:infy/data/class/user_class.dart';
import 'package:infy/data/contants/constants.dart';
import 'package:infy/data/contants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream pour écouter les changements d'authentification
  Stream<User?> get userStream {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      return await fetchUserData(firebaseUser.uid);
    });
  }

  // Récupérer l'utilisateur actuellement connecté
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    return await fetchUserData(firebaseUser.uid);
  }

  // Récupérer les données de l'utilisateur depuis Firestore
  Future<User?> fetchUserData(String uid) async {
    try {
      final userDoc =
          await _firestore
              .collection(FirebaseString.collectionUsers)
              .doc(uid)
              .get();

      if (userDoc.exists) {
        return User.fromJson({
          FirebaseString.documentId: userDoc.id,
          ...userDoc.data() as Map<String, dynamic>,
        });
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }

  // Connecter un utilisateur avec son email et son mot de passe
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sauvegarde de l'état de connexion dans les SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefsString.isLoggedIn, true);

      return await fetchUserData(userCredential.user!.uid);
    } catch (e) {
      debugPrint('Erreur de connexion: $e');
      throw Exception('${AppStrings.error}: $e');
    }
  }

  // Créer un nouvel utilisateur avec email et mot de passe
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Créer le nouvel utilisateur
      final newUser = User(
        uid: userCredential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Enregistrer les informations dans Firestore
      await _firestore
          .collection(FirebaseString.collectionUsers)
          .doc(userCredential.user!.uid)
          .set(newUser.toJson());

      // Sauvegarde de l'état de connexion dans les SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefsString.isLoggedIn, true);

      return newUser;
    } catch (e) {
      debugPrint('Erreur lors de la création du compte: $e');
      throw Exception('${AppStrings.error}: $e');
    }
  }

  // Mettre à jour les informations d'un utilisateur
  Future<User?> updateUserInfo(User user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection(FirebaseString.collectionUsers)
          .doc(user.uid)
          .update(updatedUser.toJson());

      return updatedUser;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du profil: $e');
      throw Exception('${AppStrings.errorUpdatingProfile}: $e');
    }
  }

  // Déconnecter l'utilisateur
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();

      // Suppression de l'état de connexion dans les SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefsString.isLoggedIn, false);
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      throw Exception('${AppStrings.errorLogout}: $e');
    }
  }

  // Méthode pour réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Erreur lors de la réinitialisation du mot de passe: $e');
      throw Exception('${AppStrings.error}: $e');
    }
  }

  // Méthode pour stocker les données utilisateur localement
  Future<void> storeUserDataLocally(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefsString.userId, user.uid);
      await prefs.setString(PrefsString.userEmail, user.email);
      await prefs.setString(PrefsString.userFirstName, user.firstName);
      await prefs.setString(PrefsString.userLastName, user.lastName);
    } catch (e) {
      debugPrint('Erreur lors du stockage des données locales: $e');
    }
  }

  // Méthode pour récupérer les données utilisateur localement
  Future<User?> getUserDataLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString(PrefsString.userId);

      if (uid == null || uid.isEmpty) {
        return null;
      }

      return User(
        uid: uid,
        email: prefs.getString(PrefsString.userEmail) ?? '',
        firstName: prefs.getString(PrefsString.userFirstName) ?? '',
        lastName: prefs.getString(PrefsString.userLastName) ?? '',
        createdAt:
            DateTime.now(), // Valeur par défaut, car non stockée localement
        updatedAt:
            DateTime.now(), // Valeur par défaut, car non stockée localement
      );
    } catch (e) {
      debugPrint('Erreur lors de la récupération des données locales: $e');
      return null;
    }
  }

  // Méthode pour effacer les données utilisateur stockées localement
  Future<void> clearLocalUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(PrefsString.userId);
      await prefs.remove(PrefsString.userEmail);
      await prefs.remove(PrefsString.userFirstName);
      await prefs.remove(PrefsString.userLastName);
      await prefs.remove(PrefsString.userPhotoUrl);
    } catch (e) {
      debugPrint('Erreur lors de la suppression des données locales: $e');
    }
  }
}

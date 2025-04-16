import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infy/data/contants/constants.dart';

class User {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory pour créer un User à partir d'un document Firestore
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json[FirebaseString.documentId] as String,
      email: json[FirebaseString.userEmail] as String,
      firstName: json[FirebaseString.userFirstname] as String,
      lastName: json[FirebaseString.userLastname] as String,
      createdAt:
          json[FirebaseString.userCreatedAt] is Timestamp
              ? (json[FirebaseString.userCreatedAt] as Timestamp).toDate()
              : DateTime.parse(json[FirebaseString.userCreatedAt] as String),
      updatedAt:
          json[FirebaseString.userUpdatedAt] is Timestamp
              ? (json[FirebaseString.userUpdatedAt] as Timestamp).toDate()
              : DateTime.parse(json[FirebaseString.userUpdatedAt] as String),
    );
  }

  // Méthode pour convertir un User en Map (pour Firestore)
  Map<String, dynamic> toJson() {
    return {
      FirebaseString.userEmail: email,
      FirebaseString.userFirstname: firstName,
      FirebaseString.userLastname: lastName,
      FirebaseString.userCreatedAt: createdAt.toIso8601String(),
      FirebaseString.userUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  // Méthode pour créer une copie de l'utilisateur avec des modifications
  User copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? photoURL,
    Map<String, dynamic>? additionalInfo,
    DateTime? updatedAt,
  }) {
    return User(
      uid: this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Création d'un utilisateur vide (utilisé pour l'initialisation)
  static User empty() {
    return User(
      uid: '',
      email: '',
      firstName: '',
      lastName: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

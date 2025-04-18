import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infy/contants/constants.dart';

import 'package:infy/class/class_utils/patient_utils.dart'; // Import pour générer un ID aléatoire

class Patient {
  final String firstName; // First name of the patient
  final String lastName; // Last name of the patient
  final DateTime dob; // Date de naissance
  final String documentId; // ID court du patient
  final String? address; // Address of the patient (optional)
  final Map<String, dynamic>?
  additionalInfo; // Informations médicales (optionnel)
  final List<String> caregivers; // Liste des UUID des infirmiers

  Patient({
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.documentId,
    this.address,
    this.additionalInfo,
    required this.caregivers,
  });

  // Factory pour créer un Patient à partir d'un document Firestore
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      documentId: json[FirebaseString.documentId] as String,
      firstName: json[FirebaseString.patientFirstname] as String,
      lastName: json[FirebaseString.patientLastname] as String,
      dob:
          json[FirebaseString.patientDob] is Timestamp
              ? (json[FirebaseString.patientDob] as Timestamp).toDate()
              : DateTime.parse(
                json[FirebaseString.patientDob] as String,
              ), // Gérer les chaînes
      address: json[FirebaseString.patientaddress] as String?,
      additionalInfo:
          json[FirebaseString.patientOtherInfo] as Map<String, dynamic>?,
      caregivers: List<String>.from(
        json[FirebaseString.patientCaregivers] ?? [],
      ), // Conversion de la liste
    );
  }

  // Méthode pour convertir un Patient en Map (pour Firestore)
  Map<String, dynamic> toJson() {
    return {
      FirebaseString.patientFirstname: firstName,
      FirebaseString.patientLastname: lastName,
      FirebaseString.patientDob: dob.toIso8601String(),
      FirebaseString.patientaddress: address,
      FirebaseString.patientOtherInfo: additionalInfo,
      FirebaseString.patientCaregivers: caregivers, // Ajout du champ infirmiers
    };
  }

  // Factory pour créer un Patient avec un ID vérifié et générer les mots-clés
  static Future<Patient> create({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required String? address,
    Map<String, dynamic>? otherInfo,
    required List<String> caregivers,
  }) async {
    final documentId = await PatientUtils.generateVerifiedUniqueId();
    return Patient(
      firstName: firstName,
      lastName: lastName,
      dob: birthDate,
      documentId: documentId,
      address: address,
      additionalInfo: otherInfo,
      caregivers: caregivers,
    );
  }

  Patient copyWith({
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? address,
    Map<String, dynamic>? additionalInfo,
    List<String>? caregivers,
  }) {
    return Patient(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      documentId: documentId,
      address: address ?? this.address,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      caregivers: caregivers ?? this.caregivers,
    );
  }

  static Patient empty() {
    return Patient(
      firstName: '',
      lastName: '',
      dob: DateTime.now(),
      documentId: '',
      address: '',
      additionalInfo: null,
      caregivers: [],
    );
  }
}

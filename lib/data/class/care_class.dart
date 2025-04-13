import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infy/data/constants.dart';

class Care {
  final String documentId;
  final String caregiverId;
  final String patientId;
  final Timestamp timestamp;
  final Map<String, double> coordinates;
  final List<String> carePerformed;
  final String? info;

  Care({
    required this.documentId,
    required this.caregiverId,
    required this.patientId,
    required this.timestamp,
    required this.coordinates,
    required this.carePerformed,
    this.info,
  });

  factory Care.fromJson(Map<String, dynamic> json) {
    return Care(
      documentId: json[FirebaseString.documentId] as String,
      caregiverId: json[FirebaseString.caregiverId] as String,
      patientId: json[FirebaseString.patientId] as String,
      timestamp: json[FirebaseString.timestamp] as Timestamp,
      coordinates: Map<String, double>.from(
        json[FirebaseString.careCoordinate] ?? {},
      ),
      carePerformed: List<String>.from(
        json[FirebaseString.carePerformed] ?? [],
      ),
      info: json[FirebaseString.careInfo] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirebaseString.caregiverId: caregiverId,
      FirebaseString.patientId: patientId,
      FirebaseString.timestamp: timestamp,
      FirebaseString.careCoordinate: coordinates,
      FirebaseString.carePerformed: carePerformed,
      FirebaseString.careInfo: info,
    };
  }

  static Future<Care> create({
    required String careId,
    required String caretakerId,
    required String patientId,
    required Timestamp timestamp,
    required Map<String, double> coordinates,
    required List<String> carePerformed,
    required List<String> photos,
    String? info,
  }) async {
    return Care(
      documentId: careId,
      caregiverId: caretakerId,
      patientId: patientId,
      timestamp: timestamp,
      coordinates: coordinates,
      carePerformed: carePerformed,
      info: info,
    );
  }

  Care copyWith({
    String? documentId,
    String? caregiverId,
    String? patientId,
    Timestamp? timestamp,
    Map<String, double>? coordinates,
    List<String>? carePerformed,
    List<String>? photos,
    String? info,
  }) {
    return Care(
      documentId: this.documentId,
      caregiverId: caregiverId ?? this.caregiverId,
      patientId: patientId ?? this.patientId,
      timestamp: timestamp ?? this.timestamp,
      coordinates: coordinates ?? this.coordinates,
      carePerformed: carePerformed ?? this.carePerformed,
      info: info ?? this.info,
    );
  }
}

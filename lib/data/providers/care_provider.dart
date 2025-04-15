import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/strings.dart';
import 'package:infy/utils/app_logger.dart';
import 'package:intl/intl.dart';

class CareProvider with ChangeNotifier {
  final Map<String, Care> _care = {}; // Liste principale des soins
  bool _isLoading = false;

  Map<String, Care> get cares => _care;
  bool get isLoading => _isLoading;

  Future<void> deleteCare({
    required Care care,
    required Patient patient,
  }) async {
    AppLogger.debug(
      StackTrace.current,
      'DeleteCare: ${care.documentId} for patient: ${patient.documentId}',
    );
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseString.collectionCares)
          .doc(care.documentId)
          .delete();

      // Supprimer le soin localement
      _care.remove(care.documentId);

      notifyListeners();
    } catch (e) {
      debugPrint('${AppStrings.errorDeletingItem} ${AppStrings.care}: $e');
      throw Exception('${AppStrings.errorDeletingItem} ${AppStrings.care}');
    }
  }

  Future<void> submitCare({required Care care}) async {
    try {
      if (kDebugMode) {
        debugPrint('SubmitCare: ${care.toJson()}');
      }
      final docRef = FirebaseFirestore.instance
          .collection(FirebaseString.collectionCares)
          .doc(care.documentId);

      await docRef.set(care.toJson(), SetOptions(merge: true));
      // Mettre à jour le soin localement
      _care[care.documentId] = care;

      notifyListeners();
    } catch (e) {
      debugPrint('${AppStrings.errorSubmittingItem} ${AppStrings.care}: $e');
      throw Exception('${AppStrings.errorSubmittingItem} ${AppStrings.care}');
    }
  }

  /// Récupérer les soins par patient
  Future<List<Care>> fetchByPatient(
    String patientId, {
    bool reload = false,
  }) async {
    AppLogger.debug(StackTrace.current, 'FetchByPatient: $patientId');

    // Vérifier si les soins existent déjà et si le rechargement est nécessaire
    if (!reload) {
      final List<Care> existingCares =
          _care.entries
              .where((entry) => entry.key.contains(patientId))
              .map((entry) => entry.value)
              .toList();

      if (existingCares.isNotEmpty) {
        return existingCares; // Retourner les soins déjà chargés
      }
    }

    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not logged in.");
      }

      Query query = FirebaseFirestore.instance
          .collection(FirebaseString.collectionCares)
          .where(FirebaseString.caregiverId, isEqualTo: userId)
          .where(FirebaseString.patientId, isEqualTo: patientId)
          .orderBy(FirebaseString.timestamp, descending: false);

      final QuerySnapshot snapshot = await query.get();

      final List<Care> cares =
          snapshot.docs
              .map(
                (doc) => Care.fromJson({
                  FirebaseString.documentId: doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }),
              )
              .toList();

      // Ajouter les soins récupérés à la liste principale des soins
      for (var care in cares) {
        _care[care.documentId] = care;
      }

      notifyListeners();
      return cares;
    } catch (e) {
      debugPrint('${AppStrings.errorFetchingItem}: $e');
      throw Exception(AppStrings.errorFetchingItem);
    }
  }

  /// Récupérer un soin par son ID
  Future<Care?> fetchById(String documentId, {bool reload = false}) async {
    AppLogger.debug(StackTrace.current, 'FetchById: $documentId');

    if (_care.containsKey(documentId) && !reload) {
      return _care[documentId]; // Retourner le soin déjà chargé
    }

    try {
      final DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection(FirebaseString.collectionCares)
              .doc(documentId)
              .get();

      if (doc.exists) {
        _care[documentId] = Care.fromJson({
          FirebaseString.documentId: doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
        notifyListeners();
        return _care[documentId];
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('${AppStrings.errorFetchingItem}: $e');
      throw Exception(AppStrings.errorFetchingItem);
    }
  }

  /// Récupérer les soins pour un jour donné, si cela n'a pas encore été fait
  Future<List<Care>> fetchByDate(DateTime date) async {
    AppLogger.debug(StackTrace.current, 'FetchByDate: $date');
    _isLoading = true;
    notifyListeners();

    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(date);

    final List<Care> existingCares =
        _care.entries
            .where((entry) => entry.key.contains(formattedDate))
            .map((entry) => entry.value)
            .toList();

    if (existingCares.isNotEmpty) {
      _isLoading = false;
      notifyListeners();
      return existingCares; // Retourner les soins déjà chargés
    }

    try {
      // Si les soins n'ont pas encore été chargés, les récupérer depuis Firebase
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not logged in.");
      }

      Query query = FirebaseFirestore.instance
          .collection(FirebaseString.collectionCares)
          .where(FirebaseString.caregiverId, isEqualTo: userId)
          .where(
            FirebaseString.timestamp,
            isGreaterThanOrEqualTo: Timestamp.fromDate(
              DateTime(date.year, date.month, date.day),
            ),
          )
          .where(
            FirebaseString.timestamp,
            isLessThan: Timestamp.fromDate(
              DateTime(date.year, date.month, date.day + 1),
            ),
          )
          .orderBy(FirebaseString.timestamp, descending: false);

      final QuerySnapshot snapshot = await query.get();

      List<Care> cares =
          snapshot.docs
              .map(
                (doc) => Care.fromJson({
                  FirebaseString.documentId: doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }),
              )
              .toList();

      // Ajouter les soins récupérés à la liste principale des soins
      for (var care in cares) {
        _care[care.documentId] = care;
      }

      _isLoading = false;
      notifyListeners();
      return cares;
    } catch (e) {
      debugPrint('${AppStrings.errorFetchingItem}: $e');
      throw Exception(AppStrings.errorFetchingItem);
    }
  }
}

// Future<void> fetchCares({bool reload = false}) async {
//   if (_isLoading) return;

//   _isLoading = true;
//   notifyListeners();

//   try {
//     final String? userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) {
//       throw Exception("User not logged in.");
//     }

//     Query query = FirebaseFirestore.instance
//         .collection(FirebaseString.collectionCares)
//         .where(FirebaseString.caregiverId, isEqualTo: userId)
//         .orderBy(FirebaseString.timestamp, descending: false); // Tri par date

//     final QuerySnapshot snapshot = await query.get();

//     if (snapshot.docs.isNotEmpty) {
//       _careByPatient.clear(); // Réinitialiser les données locales

//       for (var document in snapshot.docs) {
//         final careData = document.data() as Map<String, dynamic>;
//         final patientSnapshot =
//             await FirebaseFirestore.instance
//                 .collection(FirebaseString.collectionPatients)
//                 .doc(careData[FirebaseString.patientId])
//                 .get();

//         if (patientSnapshot.exists) {
//           final patientData = patientSnapshot.data() as Map<String, dynamic>;
//           final care = Care.fromJson({
//             FirebaseString.documentId: document.id,
//             ...careData,
//           });
//           final patient = Patient.fromJson({
//             FirebaseString.documentId: patientSnapshot.id,
//             ...patientData,
//           });

//           // Ajouter le soin au patient correspondant
//           if (!_careByPatient.containsKey(patient)) {
//             _careByPatient[patient] = [];
//           }
//           _careByPatient[patient]!.add(care);
//         }
//       }
//     }
//   } catch (e) {
//     debugPrint('${AppStrings.error}: $e');
//   } finally {
//     _isLoading = false;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/strings.dart';

class CareProvider with ChangeNotifier {
  final Map<DateTime, Map<Care, Patient>> _careSummariesByDate = {};
  final List<Care> _cares = []; // Local list of cares
  bool _isLoading = false;

  Map<DateTime, Map<Care, Patient>> get careSummariesByDate =>
      _careSummariesByDate;

  List<Care> get cares => _cares;
  bool get isLoading => _isLoading;

  Future<void> fetchCareByDate(DateTime date, {bool reload = false}) async {
    // Check if cares for this date are already loaded
    if (_careSummariesByDate.containsKey(date) && !reload) return;

    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
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
          .orderBy(
            FirebaseString.timestamp,
            descending: false,
          ); // Ascending order (oldest to newest)

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final Map<Care, Patient> careSummaries = {};
        for (var document in snapshot.docs) {
          final careData = document.data() as Map<String, dynamic>;
          final patientSnapshot =
              await FirebaseFirestore.instance
                  .collection(FirebaseString.collectionPatients)
                  .doc(careData[FirebaseString.patientId])
                  .get();

          if (patientSnapshot.exists) {
            final patientData = patientSnapshot.data() as Map<String, dynamic>;
            final care = Care.fromJson({
              FirebaseString.documentId: document.id,
              ...careData,
            });
            final patient = Patient.fromJson({
              FirebaseString.documentId: patientSnapshot.id,
              ...patientData,
            });

            careSummaries[care] = patient;
          }
        }
        _careSummariesByDate[date] = careSummaries;
      } else {
        _careSummariesByDate[date] = {};
      }
    } catch (e) {
      print('${AppStrings.error}: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all cares from Firebase
  Future<void> fetchCares() async {
    _isLoading = true;
    notifyListeners();

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection(FirebaseString.collectionCares)
              .orderBy(FirebaseString.timestamp, descending: true)
              .get();

      _cares.clear();
      _cares.addAll(
        snapshot.docs.map((doc) {
          return Care.fromJson(doc.data() as Map<String, dynamic>);
        }).toList(),
      );
    } catch (e) {
      debugPrint('${AppStrings.errorFetchingItem} ${AppStrings.care}: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new care to Firebase
  Future<void> addCare(Care care) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection(FirebaseString.collectionCares)
          .add(care.toJson());
      final newCare = care.copyWith(caregiverId: docRef.id);
      _cares.add(newCare);
      notifyListeners(); // Notify listeners after adding care
    } catch (e) {
      debugPrint('${AppStrings.errorAddingItem} ${AppStrings.care}: $e');
    }
  }

  /// Update an existing care in Firebase
  Future<void> updateCare(String id, Care updatedCare) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseString.collectionCares)
          .doc(id)
          .update(updatedCare.toJson());
      final index = _cares.indexWhere((care) => care.caregiverId == id);
      if (index != -1) {
        _cares[index] = updatedCare;
        notifyListeners(); // Notify listeners after updating care
      }
    } catch (e) {
      debugPrint('${AppStrings.errorUpdatingItem} ${AppStrings.care}: $e');
    }
  }

  /// Delete a care from Firebase
  Future<void> deleteCareById(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseString.collectionCares)
          .doc(id)
          .delete();
      _cares.removeWhere((care) => care.caregiverId == id);
      notifyListeners(); // Notify listeners after deleting care
    } catch (e) {
      debugPrint('${AppStrings.errorDeletingItem} ${AppStrings.care}: $e');
      throw Exception('${AppStrings.errorDeletingItem} ${AppStrings.care}');
    }
  }

  Future<void> deleteCare(Care care) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseString.collectionCares)
          .doc(care.caregiverId)
          .delete();
      _cares.remove(care);
      notifyListeners(); // Notify listeners after deleting care
    } catch (e) {
      debugPrint('${AppStrings.errorDeletingItem} ${AppStrings.care}: $e');
      throw Exception('${AppStrings.errorDeletingItem} ${AppStrings.care}');
    }
  }

  Future<void> submitCare({required Care care}) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(FirebaseString.collectionCares)
          .doc(care.documentId);

      await docRef.set(care.toJson(), SetOptions(merge: true));

      final index = _cares.indexWhere((c) => c.documentId == care.documentId);
      if (index != -1) {
        _cares[index] = care;
      } else {
        _cares.add(care);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('${AppStrings.errorSubmittingItem} ${AppStrings.care}: $e');
      throw Exception('${AppStrings.errorSubmittingItem} ${AppStrings.care}');
    }
  }
}

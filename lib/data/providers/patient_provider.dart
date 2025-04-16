import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infy/data/contants/constants.dart';
import 'package:infy/data/contants/strings.dart';
import '../class/patient_class.dart';

class PatientProvider with ChangeNotifier {
  final Map<String, Patient> _patients = {};

  bool _isLoading = false;
  bool _hasMore = true;
  final int _batchSize = 7;
  List<Patient> _filteredPatients = [];
  DocumentSnapshot? _lastDocument;

  Map<String, Patient> get patients => _patients;
  List<Patient> get filteredPatients => _filteredPatients;
  bool get isLoading => _isLoading;

  /// Fetch initial batch of patients
  Future<void> fetchPatients({bool reload = false}) async {
    if (_isLoading) return;

    if (reload) {
      _patients.clear();
      _filteredPatients.clear();
      _lastDocument = null;
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();
    try {
      Query query = FirebaseFirestore.instance
          .collection(FirebaseString.collectionPatients)
          .where(
            FirebaseString.patientCaregivers,
            arrayContains: FirebaseAuth.instance.currentUser?.uid,
          )
          .orderBy(FirebaseString.patientLastname)
          .limit(_batchSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        for (var document in snapshot.docs) {
          final data = document.data() as Map<String, dynamic>;
          final patient = Patient.fromJson({
            FirebaseString.documentId: document.id,
            ...data,
          });
          _patients[document.id] = patient;
        }
        _lastDocument = snapshot.docs.last;
      } else {
        _hasMore = false; // No more patients to load
      }

      _filteredPatients = _patients.values.toList();
    } catch (e) {
      debugPrint('${AppStrings.errorFetchingItem} ${AppStrings.patient}: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch more patients for pagination
  Future<void> fetchMorePatients() async {
    if (_isLoading || !_hasMore) return;
    await fetchPatients();
  }

  /// Filter patients based on search query
  void filterPatients(String query) {
    query = query.toLowerCase();
    if (query.isEmpty) {
      _filteredPatients = _patients.values.toList();
    } else {
      _filteredPatients =
          _patients.values.where((patient) {
            final fullName =
                '${patient.firstName} ${patient.lastName}'.toLowerCase();
            final adresse = (patient.address ?? '').toLowerCase();
            return fullName.contains(query) || adresse.contains(query);
          }).toList();
    }
    notifyListeners();
  }

  Future<String> addCaregiver(String patientId) async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception(AppStrings.userNotLoggedIn);
      }

      // Retrieve the patient from Firebase
      Patient? patient = _patients[patientId];
      if (patient == null) {
        patient = await fetchPatientById(patientId);
        if (patient == null) {
          throw Exception(AppStrings.patientNotFound);
        }
      }
      // Convert the document into a Patient object
      final patientUpdated = Patient.fromJson({
        FirebaseString.patientCaregivers: [
          ...patient.caregivers,
          FirebaseAuth.instance.currentUser?.uid,
        ],
        ...patient.toJson(),
      });

      // Add the user's UUID to the list of nurses
      if (!patient.caregivers.contains(userId)) {
        final updatedCaregivers = List<String>.from(patient.caregivers)
          ..add(userId);
        await FirebaseFirestore.instance
            .collection(FirebaseString.collectionPatients)
            .doc(patientId)
            .update({FirebaseString.patientCaregivers: updatedCaregivers});

        _patients[patientId] = patientUpdated;
        notifyListeners();
        return AppStrings.addedAsCaregiver;
      } else {
        return AppStrings.alreadyCaregiver;
      }
    } catch (e) {
      throw '${AppStrings.error}: $e';
    }
  }

  Future<void> submit(Patient patient) async {
    try {
      // Enregistrer le patient dans Firestore
      await FirebaseFirestore.instance
          .collection(FirebaseString.collectionPatients)
          .doc(patient.documentId)
          .set(patient.toJson());
      _patients[patient.documentId] = patient;
      notifyListeners();
    } catch (e) {
      debugPrint('${AppStrings.errorSubmittingItem} ${AppStrings.patient}: $e');
      throw Exception(
        '${AppStrings.errorSubmittingItem} ${AppStrings.patient}',
      );
    }
  }

  /// Récupérer un patient en fonction de son patientID
  Future<Patient?> fetchPatientById(String patientId) async {
    try {
      // Vérifier si le patient est déjà dans la liste
      if (_patients.containsKey(patientId)) {
        return _patients[patientId]; // Retourner le patient déjà chargé
      }

      // Si le patient n'est pas dans la liste, le récupérer depuis Firestore
      final DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection(FirebaseString.collectionPatients)
              .doc(patientId)
              .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final patient = Patient.fromJson({
          FirebaseString.documentId: doc.id,
          ...data,
        });

        // Ajouter le patient à la liste locale
        _patients[patient.documentId] = patient;
        notifyListeners();

        return patient;
      } else {
        return null; // Patient non trouvé
      }
    } catch (e) {
      debugPrint('${AppStrings.errorFetchingItem} ${AppStrings.patient}: $e');
      throw Exception('${AppStrings.errorFetchingItem} ${AppStrings.patient}');
    }
  }
}

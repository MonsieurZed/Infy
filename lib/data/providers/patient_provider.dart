import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/strings.dart';
import '../class/patient_class.dart';

class PatientProvider with ChangeNotifier {
  final List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument; // For pagination
  final int _batchSize = 10; // Number of patients to load per batch
  bool _hasMore = true; // Indicates if more patients are available

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
          _patients.add(patient);
        }
        _lastDocument = snapshot.docs.last;
      } else {
        _hasMore = false; // No more patients to load
      }

      _filteredPatients = List.from(_patients);
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
      _filteredPatients = List.from(_patients);
    } else {
      _filteredPatients =
          _patients.where((patient) {
            final fullName =
                '${patient.firstName} ${patient.lastName}'.toLowerCase();
            final adresse = (patient.address ?? '').toLowerCase();
            return fullName.contains(query) || adresse.contains(query);
          }).toList();
    }
    notifyListeners();
  }

  Future<void> addNurseToPatient(String patientId, BuildContext context) async {
    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.enterValidPatientId)),
      );
      return;
    }

    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception(AppStrings.userNotLoggedIn);
      }

      // Retrieve the patient from Firebase
      final DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection(FirebaseString.collectionPatients)
              .doc(patientId)
              .get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.noPatientFound)),
        );
        return;
      }

      // Convert the document into a Patient object
      final patientData = doc.data() as Map<String, dynamic>;
      final patient = Patient.fromJson({
        FirebaseString.documentId: doc.id,
        ...patientData,
      });

      // Add the user's UUID to the list of nurses
      if (!patient.caregivers.contains(userId)) {
        final updatedCaregivers = List<String>.from(patient.caregivers)
          ..add(userId);
        await FirebaseFirestore.instance
            .collection(FirebaseString.collectionPatients)
            .doc(patientId)
            .update({FirebaseString.patientCaregivers: updatedCaregivers});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.addedAsCaregiver)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.alreadyCaregiver)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${AppStrings.error}: $e')));
    }
  }

  Future<void> savePatient(
    TextEditingController firstnameController,
    TextEditingController lastNameController,
    TextEditingController rueController,
    TextEditingController codePostalController,
    TextEditingController villeController,
    DateTime? birthDate,
    Patient? patient,
    BuildContext context,
  ) async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception(AppStrings.userNotLoggedIn);
      }

      // Build the address in the French format
      final adresse =
          '${rueController.text.trim()}, ${codePostalController.text.trim()}, ${villeController.text.trim()}';

      // Create a new Patient object
      final newPatient =
          patient == null
              ? await Patient.createWithVerifiedId(
                firstName: firstnameController.text.trim(),
                lastName: lastNameController.text.trim(),
                birthDate: birthDate!,
                address: adresse,
                otherInfo: null,
                infirmiers: [userId], // Add the user's UUID
              )
              : patient.copyWith(
                firstName: firstnameController.text.trim(),
                lastName: lastNameController.text.trim(),
                dob: birthDate!,
                address: adresse,
              );

      // Save to Firestore
      if (patient == null) {
        // Add a new patient
        await FirebaseFirestore.instance
            .collection(FirebaseString.collectionPatients)
            .doc(newPatient.documentId)
            .set(newPatient.toJson());
      } else {
        // Update an existing patient
        await FirebaseFirestore.instance
            .collection(FirebaseString.collectionPatients)
            .doc(newPatient.documentId)
            .update(newPatient.toJson());
      }

      // Repull patient data

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.patientSavedSuccessfully)),
      );
      Navigator.pop(
        context,
      ); // Return to the previous page with the updated patient
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${AppStrings.error}: $e')));
    }
  }
}

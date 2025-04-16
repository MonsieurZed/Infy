import 'package:flutter/material.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:infy/data/contants/constants.dart';
import 'package:infy/data/contants/strings.dart';
import 'package:infy/views/pages/caregivers/patient/widget/patient_patient_widget.dart';
import 'package:infy/views/pages/caregivers/patient/patient_addedit_page.dart';
import 'package:infy/views/pages/caregivers/care/care_addedit_page.dart'; // Added import for AddEditCarePage
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:infy/data/providers/patient_provider.dart';
import 'package:infy/data/providers/care_provider.dart';

class ShowPatientPage extends StatefulWidget {
  final String patientId;

  const ShowPatientPage({super.key, required this.patientId});

  @override
  State<ShowPatientPage> createState() => _ShowPatientPageState();
}

class _ShowPatientPageState extends State<ShowPatientPage> {
  List<Care> _cares = [];
  bool _isLoading = true;
  Patient? _patient;

  @override
  void initState() {
    super.initState();
    _fetchCares();
    _loadPatient();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les soins à chaque fois que les dépendances changent (par exemple à la navigation)
    _fetchCares();
  }

  // Cette méthode est appelée lorsqu'on revient à cette page après navigation
  @override
  void didUpdateWidget(ShowPatientPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si on revient sur la même page mais avec un ID différent, recharger les données
    if (oldWidget.patientId != widget.patientId) {
      _fetchCares();
      _loadPatient();
    }
  }

  Future<void> _loadPatient() async {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    try {
      final patient = await patientProvider.fetchPatientById(widget.patientId);
      setState(() {
        _patient = patient;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.errorRetrievingitem} ${AppStrings.patient} : $e',
          ),
        ),
      );
    }
  }

  Future<void> _fetchCares() async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception(AppStrings.userNotLoggedIn);
      }

      // Utiliser le CareProvider pour récupérer les soins du patient
      final careProvider = Provider.of<CareProvider>(context, listen: false);
      final cares = await careProvider.fetchByPatient(widget.patientId);

      setState(() {
        _cares = cares;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.errorRetrievingitem} ${AppStrings.care} : $e',
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.confirmationTitle),
          content: const Text(AppStrings.removePatientPrompt),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: const Text(AppStrings.cancelButton),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              child: const Text(AppStrings.confirmButton),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _removeCaregiverAndExit(context);
    }
  }

  Future<void> _removeCaregiverAndExit(BuildContext context) async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception(AppStrings.userNotLoggedIn);
      }

      if (_patient == null) {
        await _loadPatient();
        if (_patient == null) {
          throw Exception(AppStrings.patientNotFound);
        }
      }

      if (_patient!.caregivers.contains(userId)) {
        final updatedNurses = List<String>.from(_patient!.caregivers)
          ..remove(userId);

        await FirebaseFirestore.instance
            .collection(FirebaseString.collectionPatients)
            .doc(widget.patientId)
            .update({FirebaseString.patientCaregivers: updatedNurses});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.removedFromPatient)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.notCaregiverForPatient)),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${AppStrings.error}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.patientDetailsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: AppStrings.editPatientTooltip,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AddPatientPage(patientId: widget.patientId),
                ),
              ).then((_) {
                // Forcer le rechargement des données lorsqu'on revient de l'édition du patient
                setState(() {
                  _loadPatient();
                });
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: AppStrings.removePatientTooltip,
            onPressed: () async {
              await _showConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display patient information from Provider
            Consumer<PatientProvider>(
              builder: (context, patientProvider, child) {
                if (_patient == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      '${_patient!.firstName} ${_patient!.lastName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      '${AppStrings.dateOfBirth}: ${DateFormat(AppConstants.dateFormat).format(_patient!.dob)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      '${AppStrings.address}: ${_patient!.address ?? AppStrings.notProvided}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      '${AppStrings.patientId}: ${_patient!.documentId}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.careListTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _cares.isEmpty
                      ? const Center(child: Text(AppStrings.noCareFound))
                      : ListView.builder(
                        itemCount: _cares.length,
                        itemBuilder: (context, index) {
                          final care = _cares[index];
                          return PatientPatientWidget(
                            care: care,
                            patientId: widget.patientId,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _patient != null
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              AddEditCarePage(patient: _patient!, care: null),
                    ),
                  ).then((_) {
                    // Refresh cares list when returning from the add page
                    _fetchCares();
                  });
                },
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}

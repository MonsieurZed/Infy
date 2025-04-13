import 'package:flutter/material.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/views/widgets/care_widget.dart';
import 'package:infy/views/pages/nurse/patient/add_edit_patient_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:infy/data/strings.dart';

class ShowPatientPage extends StatefulWidget {
  final Patient patient;

  const ShowPatientPage({super.key, required this.patient});

  @override
  State<ShowPatientPage> createState() => _ShowPatientPageState();
}

class _ShowPatientPageState extends State<ShowPatientPage> {
  List<Care> _cares = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCares();
  }

  Future<void> _fetchCares() async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception(AppStrings.userNotLoggedIn);
      }

      // Query to retrieve care associated with the patient and nurse
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection(FirebaseString.collectionCares)
              .where(
                FirebaseString.patientId,
                isEqualTo: widget.patient.documentId,
              )
              .where(FirebaseString.caregiverId, isEqualTo: userId)
              .orderBy(FirebaseString.timestamp, descending: true)
              .get();

      final List<Care> cares =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Care.fromJson({FirebaseString.documentId: doc.id, ...data});
          }).toList();

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
      await _removeNurseAndExit(context);
    }
  }

  Future<void> _removeNurseAndExit(BuildContext context) async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception(AppStrings.userNotLoggedIn);
      }

      if (widget.patient.caregivers.contains(userId)) {
        final updatedNurses = List<String>.from(widget.patient.caregivers)
          ..remove(userId);

        await FirebaseFirestore.instance
            .collection(FirebaseString.collectionPatients)
            .doc(widget.patient.documentId)
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
                  builder: (context) => AddPatientPage(patient: widget.patient),
                ),
              );
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
            // Display patient information
            SelectableText(
              '${widget.patient.firstName} ${widget.patient.lastName}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              '${AppStrings.dateOfBirth}: ${DateFormat(AppConstants.dateFormat).format(widget.patient.dob)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            SelectableText(
              '${AppStrings.address}: ${widget.patient.address ?? AppStrings.notProvided}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            SelectableText(
              '${AppStrings.patientId}: ${widget.patient.documentId}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.careListTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
                          return CareWidget(
                            care: care,
                            patient: widget.patient,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/strings.dart';
import 'package:infy/views/widgets/patient_care_widget.dart';

class PatientCarePage extends StatefulWidget {
  const PatientCarePage({super.key, required this.patientId});

  final String patientId;

  @override
  State<PatientCarePage> createState() => _PatientCarePageState();
}

class _PatientCarePageState extends State<PatientCarePage> {
  final Map<Care, String> _careList = {};
  bool _isLoading = true;
  DocumentSnapshot? _lastDocument; // Last document for pagination
  final int _batchSize = 10; // Number of items to load per batch
  final Map<String, String> _caregiverCache = {}; // Cache for caregiver names

  @override
  void initState() {
    super.initState();
    _fetchCares();
  }

  Future<void> _fetchCares() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection(FirebaseString.collectionCares)
          .where(FirebaseString.patientId, isEqualTo: widget.patientId)
          .orderBy(FirebaseString.timestamp, descending: true)
          .limit(_batchSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        for (var document in snapshot.docs) {
          final data = document.data() as Map<String, dynamic>;
          final caregiverId = data[FirebaseString.caregiverId] as String;

          // Check if the caregiver is already in the cache
          if (!_caregiverCache.containsKey(caregiverId)) {
            final caregiverSnapshot =
                await FirebaseFirestore.instance
                    .collection(FirebaseString.collectionUsers)
                    .doc(caregiverId)
                    .get();

            if (caregiverSnapshot.exists) {
              final caregiverData =
                  caregiverSnapshot.data() as Map<String, dynamic>;
              _caregiverCache[caregiverId] =
                  "${caregiverData[FirebaseString.patientFirstname]} ${caregiverData[FirebaseString.patientLastname]}";
            } else {
              _caregiverCache[caregiverId] = AppStrings.caregiverNotFound;
            }
          }

          // Create an instance of Care
          final care = Care.fromJson(data);

          _careList[care] = _caregiverCache[caregiverId]!;
        }

        setState(() {
          _lastDocument = snapshot.docs.last; // Update the last document
        });
      } else if (_careList.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.noCareFound)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${AppStrings.error}: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.careListTitle)),
      body:
          _isLoading && _careList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _careList.length,
                itemBuilder: (context, index) {
                  final entry = _careList.entries.toList()[index];
                  final care = entry.key;
                  final caretakerName = entry.value;
                  return PatientCareWidget(
                    care: care,
                    caregiverName: caretakerName,
                  );
                },
              ),
    );
  }
}

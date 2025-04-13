import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/class/care_item_class.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/providers/care_provider.dart';
import 'package:intl/intl.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:provider/provider.dart';
import 'package:infy/data/providers/care_item_provider.dart';
import 'package:infy/data/strings.dart';

class AddEditCarePage extends StatefulWidget {
  const AddEditCarePage({
    super.key,
    required this.patient,
    this.care, // Paramètre optionnel pour l'objet Care
  });

  final Patient patient;
  final Care? care; // Objet Care optionnel

  @override
  State<AddEditCarePage> createState() => _AddEditCarePageState();
}

class _AddEditCarePageState extends State<AddEditCarePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _infoController = TextEditingController();

  DateTime? _selectedTimestamp;
  List<String> _selectedCareItems = [];

  @override
  void initState() {
    super.initState();

    // Charger les données si un objet Care est fourni
    if (widget.care != null) {
      final care = widget.care!;
      _selectedTimestamp = care.timestamp.toDate();
      _selectedCareItems = List.from(care.carePerformed);
      _infoController.text = care.info ?? '';
    } else {
      _selectedTimestamp = DateTime.now();
    }
  }

  Future<void> _submitCare() async {
    if (!_formKey.currentState!.validate()) return;

    final String? caretakerId = FirebaseAuth.instance.currentUser?.uid;
    if (caretakerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.userNotLoggedIn)));
      return;
    }

    final care = Care(
      documentId:
          widget.care?.documentId ??
          widget.patient.documentId +
              DateFormat('yyyyMMddHHmmss').format(_selectedTimestamp!),
      caregiverId: caretakerId,
      patientId: widget.patient.documentId,
      timestamp: Timestamp.fromDate(_selectedTimestamp ?? DateTime.now()),
      coordinates: {}, // Coordonnées GPS
      carePerformed: _selectedCareItems,
      info: _infoController.text.trim(),
    );

    try {
      await Provider.of<CareProvider>(
        context,
        listen: false,
      ).submitCare(care: care);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.care != null
                ? AppStrings.careUpdatedSuccessfully
                : AppStrings.careAddedSuccessfully,
          ),
        ),
      );

      Provider.of<CareProvider>(
        context,
        listen: false,
      ).fetchCareByDate(_selectedTimestamp ?? DateTime.now(), reload: true);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${AppStrings.error}: $e')));
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedTimestamp ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedTimestamp ?? DateTime.now(),
        ),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedTimestamp = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.care != null ? AppStrings.editCare : AppStrings.addCare,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.patient}: ${widget.patient.firstName} ${widget.patient.lastName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickDateTime,
                child: Text(
                  _selectedTimestamp == null
                      ? AppStrings.selectDateTime
                      : DateFormat(
                        AppConstants.classicTimeFormat,
                      ).format(_selectedTimestamp!),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<CareItemProvider>(
                builder: (context, careItemProvider, child) {
                  final careItems = careItemProvider.careItems;
                  final groupedCareItems = <String, List<CareItem>>{};

                  for (var careItem in careItems) {
                    groupedCareItems
                        .putIfAbsent(careItem.careType, () => [])
                        .add(careItem);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        groupedCareItems.entries.map((entry) {
                          final careType = entry.key;
                          final items = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                careType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 4.0,
                                runSpacing: 4.0,
                                children:
                                    items.map((careItem) {
                                      final isSelected = _selectedCareItems
                                          .contains(careItem.documentId);
                                      return SizedBox(
                                        width: 100,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              if (isSelected) {
                                                _selectedCareItems.remove(
                                                  careItem.documentId,
                                                );
                                              } else {
                                                _selectedCareItems.add(
                                                  careItem.documentId,
                                                );
                                              }
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                isSelected
                                                    ? Colors.teal[100]
                                                    : Colors.white10,
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(careItem.name),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _infoController,
                decoration: const InputDecoration(
                  labelText: AppStrings.annotationLabel,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitCare,
                  child: Text(
                    widget.care != null ? AppStrings.update : AppStrings.add,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

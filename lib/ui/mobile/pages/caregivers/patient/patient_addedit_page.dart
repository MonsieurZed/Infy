import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infy/class/patient_class.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/utils/input_formater.dart';
import 'package:provider/provider.dart';
import 'package:infy/providers/patient_provider.dart';

class AddPatientPage extends StatefulWidget {
  final Patient? patient; // Existing patient for editing (null for adding)
  final String?
  patientId; // Alternative: patient ID for editing (null for adding)

  const AddPatientPage({super.key, this.patient, this.patientId})
    : assert(
        (patient == null && patientId == null) ||
            (patient != null) ^ (patientId != null),
        'Provide either patient or patientId, not both',
      );

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final TextEditingController _patientIdController = TextEditingController();

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _rueController = TextEditingController();
  final TextEditingController _codePostalController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  DateTime? _birthDate;

  final GlobalKey<FormState> _patientIdKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _patientFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Si nous avons un objet patient, utilisez-le directement
    if (widget.patient != null) {
      _populateFieldsFromPatient(widget.patient!);
    }
    // Si nous avons un ID de patient, chargez-le depuis Firebase
    else if (widget.patientId != null) {
      _loadPatientData();
    }
  }

  void _populateFieldsFromPatient(Patient patient) {
    _firstnameController.text = patient.firstName;
    _lastNameController.text = patient.lastName;

    // Si l'adresse existe, divisez-la en ses composants
    if (patient.address != null) {
      final adresseParts = patient.address!.split(', ');
      if (adresseParts.length == 3) {
        _rueController.text = adresseParts[0];
        _codePostalController.text = adresseParts[1];
        _villeController.text = adresseParts[2];
      }
    }

    _birthDate = patient.dob;
  }

  Future<void> _loadPatientData() async {
    try {
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      final patient = await patientProvider.fetchPatientById(widget.patientId!);

      if (patient != null && mounted) {
        setState(() {
          _populateFieldsFromPatient(patient);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.errorRetrievingitem} ${AppStrings.patient}: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.patient == null
              ? AppStrings.addPatient
              : AppStrings.editPatient,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _patientIdKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top section: Add a patient via their ID (only if adding a patient)
              if (widget.patient == null)
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _patientIdController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.patientId,
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]'),
                            ), // Allow only letters and numbers
                            UpperCaseTextFormatter(), // Convert letters to uppercase
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.enterValidPatientId;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            () => patientProvider.addCaregiver(
                              _patientIdController.text.trim(),
                            ),
                        child: const Text(AppStrings.importPatient),
                      ),
                    ],
                  ),
                ),
              if (widget.patient == null)
                const Divider(height: 50, thickness: 3),

              // Bottom section: Form to add/edit a patient
              Expanded(
                flex: 4,
                child: Form(
                  key: _patientFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstnameController,
                          decoration: InputDecoration(
                            labelText: AppStrings.firstNameLabel,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    _firstnameController.text.trim().isEmpty
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.enterFirstName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: AppStrings.lastNameLabel,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    _lastNameController.text.trim().isEmpty
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.enterLastName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _rueController,
                          decoration: InputDecoration(
                            labelText: AppStrings.street,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    _rueController.text.trim().isEmpty
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.enterStreet;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _codePostalController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          decoration: InputDecoration(
                            labelText: AppStrings.postalCode,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    _codePostalController.text.trim().isEmpty
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.enterPostalCode;
                            }
                            if (value.length != 5) {
                              return AppStrings.postalCodeLength;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _villeController,
                          decoration: InputDecoration(
                            labelText: AppStrings.city,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    _villeController.text.trim().isEmpty
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.enterCity;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _birthDate == null
                                    ? AppStrings.selectDateOfBirth
                                    : "${AppStrings.dateOfBirth}: ${MaterialLocalizations.of(context).formatFullDate(_birthDate!)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      _birthDate == null
                                          ? Colors.red
                                          : Colors.black,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.calendar_today,
                                color: Colors.teal,
                              ),
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _birthDate ?? DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null && picked != _birthDate) {
                                  setState(() {
                                    _birthDate = picked;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            if (_patientFormKey.currentState!.validate()) {
                              // Cas d'édition d'un patient existant
                              if (widget.patient != null ||
                                  widget.patientId != null) {
                                // Si nous avons un ID mais pas d'objet patient, récupérez-le
                                Patient patientToUpdate =
                                    widget.patient ??
                                    (await Provider.of<PatientProvider>(
                                      context,
                                      listen: false,
                                    ).fetchPatientById(widget.patientId!))!;

                                // Mise à jour des champs du patient
                                patientToUpdate = Patient(
                                  documentId: patientToUpdate.documentId,
                                  firstName: _firstnameController.text.trim(),
                                  lastName: _lastNameController.text.trim(),
                                  address:
                                      "${_rueController.text.trim()}, ${_codePostalController.text.trim()}, ${_villeController.text.trim()}",
                                  dob: _birthDate!,
                                  caregivers: patientToUpdate.caregivers,
                                );

                                await Provider.of<PatientProvider>(
                                  context,
                                  listen: false,
                                ).submit(patientToUpdate);
                              }
                              // Cas de création d'un nouveau patient
                              else {
                                Patient newPatient = await Patient.create(
                                  firstName: _firstnameController.text.trim(),
                                  lastName: _lastNameController.text.trim(),
                                  address:
                                      "${_rueController.text.trim()}, ${_codePostalController.text.trim()}, ${_villeController.text.trim()}",
                                  birthDate: _birthDate!,
                                  caregivers: [
                                    FirebaseAuth.instance.currentUser!.uid,
                                  ],
                                );
                                await Provider.of<PatientProvider>(
                                  context,
                                  listen: false,
                                ).submit(newPatient);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    AppStrings.patientSavedSuccessfully,
                                  ),
                                ),
                              );
                              Navigator.pop(
                                context,
                                true,
                              ); // Retourner true pour indiquer succès
                            } else {
                              setState(
                                () {},
                              ); // Trigger UI update to show red borders
                            }
                          },
                          child: Text(
                            (widget.patient == null && widget.patientId == null)
                                ? AppStrings.saveNewPatient
                                : AppStrings.saveChanges,
                          ),
                        ),
                      ],
                    ),
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:infy/data/strings.dart';
import 'package:infy/data/utils/inputformater.dart';
import 'package:provider/provider.dart';
import 'package:infy/data/providers/patient_provider.dart';

class AddPatientPage extends StatefulWidget {
  final Patient? patient; // Existing patient for editing (null for adding)

  const AddPatientPage({super.key, this.patient});

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
    if (widget.patient != null) {
      // Pre-fill fields for editing
      _firstnameController.text = widget.patient!.firstName;
      _lastNameController.text = widget.patient!.lastName;

      // If the address exists, split it into its components
      if (widget.patient!.address != null) {
        final adresseParts = widget.patient!.address!.split(', ');
        if (adresseParts.length == 3) {
          _rueController.text = adresseParts[0];
          _codePostalController.text = adresseParts[1];
          _villeController.text = adresseParts[2];
        }
      }

      _birthDate = widget.patient!.dob;
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
                            labelText: AppStrings.firstName,
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
                            labelText: AppStrings.lastName,
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
                              Patient patient =
                                  widget.patient ??
                                  await Patient.create(
                                    firstName: _firstnameController.text.trim(),
                                    lastName: _lastNameController.text.trim(),
                                    address:
                                        "${_rueController.text.trim()}, ${_codePostalController.text.trim()}, ${_villeController.text.trim()}",
                                    birthDate: _birthDate!,
                                    caregivers: [
                                      FirebaseAuth.instance.currentUser!.uid,
                                    ],
                                  );
                              await patientProvider.submit(patient);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    AppStrings.patientSavedSuccessfully,
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              setState(
                                () {},
                              ); // Trigger UI update to show red borders
                            }
                          },
                          child: Text(
                            widget.patient == null
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

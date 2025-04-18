import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:infy/class/patient_class.dart';
import 'package:infy/contants/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientDetailForm extends StatefulWidget {
  final Patient patient;
  final Function(Patient) onSave;
  final bool isNewPatient;

  const PatientDetailForm({
    Key? key,
    required this.patient,
    required this.onSave,
    this.isNewPatient = false,
  }) : super(key: key);

  @override
  State<PatientDetailForm> createState() => _PatientDetailFormState();
}

class _PatientDetailFormState extends State<PatientDetailForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  DateTime? _selectedDate;
  bool _isLoading = false;
  Map<String, dynamic>? _additionalInfo;
  List<String> _caregivers = [];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  @override
  void didUpdateWidget(PatientDetailForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si le patient a changé, mettre à jour les contrôleurs et autres propriétés
    if (oldWidget.patient.documentId != widget.patient.documentId) {
      _initializeFormData();
    }
  }

  // Méthode pour initialiser ou réinitialiser les données du formulaire
  void _initializeFormData() {
    // Mettre à jour les contrôleurs avec les données du patient actuel
    _firstNameController = TextEditingController(
      text: widget.patient.firstName,
    );
    _lastNameController = TextEditingController(text: widget.patient.lastName);
    _addressController = TextEditingController(
      text: widget.patient.address ?? '',
    );
    _selectedDate = widget.patient.dob;
    _additionalInfo = widget.patient.additionalInfo ?? {};
    _caregivers = List.from(widget.patient.caregivers);

    // S'assurer que l'utilisateur actuel est ajouté comme soignant pour un nouveau patient
    if (widget.isNewPatient) {
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserUid != null && !_caregivers.contains(currentUserUid)) {
        _caregivers.add(currentUserUid);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: AppStrings.dateOfBirth,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedPatient =
            widget.isNewPatient
                ? await Patient.create(
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                  birthDate: _selectedDate!,
                  address: _addressController.text.trim(),
                  otherInfo: _additionalInfo,
                  caregivers: _caregivers,
                )
                : widget.patient.copyWith(
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                  dob: _selectedDate,
                  address: _addressController.text.trim(),
                  additionalInfo: _additionalInfo,
                  caregivers: _caregivers,
                );

        await widget.onSave(updatedPatient);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isNewPatient
                    ? AppStrings.patientAddedSuccessfully
                    : AppStrings.patientUpdatedSuccessfully,
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.error}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPersonalInfoSection(),
            const SizedBox(height: 8),
            _buildAdditionalInfoSection(),
            const SizedBox(height: 8),
            _buildCaregiversSection(),
            const SizedBox(height: 8),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.personalInformation,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prénom
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: AppStrings.firstNameLabel,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.firstNameRequired;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Nom de famille
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: AppStrings.lastNameLabel,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.lastNameRequired;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date de naissance
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppStrings.dateOfBirth,
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate != null
                                ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(_selectedDate!)
                                : AppStrings.selectDate,
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Âge calculé (lecture seule)
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: AppStrings.age,
                      prefixIcon: const Icon(Icons.analytics_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${DateTime.now().year - _selectedDate!.year} ${AppStrings.years}'
                          : '-',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Adresse
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: AppStrings.address,
                prefixIcon: const Icon(Icons.home_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    // Zone de notes générales pour additionalInfo
    final notesController = TextEditingController(
      text: _additionalInfo?.toString() ?? '',
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.additionalInformation,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.additionalInfoDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            // Champ de texte pour les informations additionnelles
            TextFormField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: AppStrings.notes,
                prefixIcon: const Icon(Icons.note_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 5,
              onChanged: (value) {
                // Simple stockage de texte brut dans additionalInfo
                setState(() {
                  _additionalInfo = {'notes': value};
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaregiversSection() {
    return Card();
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.save),
        label: Text(
          _isLoading
              ? AppStrings.saving
              : widget.isNewPatient
              ? AppStrings.createPatient
              : AppStrings.saveChanges,
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: _isLoading ? null : _savePatient,
      ),
    );
  }
}

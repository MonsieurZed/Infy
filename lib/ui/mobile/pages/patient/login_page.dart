import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firebase
import 'package:infy/contants/constants.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/ui/mobile/pages/patient/patient_care_page.dart'; // Import for the next page

class LoginPatientPage extends StatefulWidget {
  const LoginPatientPage({super.key});

  @override
  State<LoginPatientPage> createState() => _LoginPatientPageState();
}

class _LoginPatientPageState extends State<LoginPatientPage> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCode({bool skipValidation = false}) async {
    if (skipValidation || _formKey.currentState!.validate()) {
      final String code = _codeController.text.trim();

      // Check if the patient code exists in Firebase
      try {
        final DocumentSnapshot snapshot =
            await FirebaseFirestore.instance
                .collection(FirebaseString.collectionPatients)
                .doc(code)
                .get();

        if (snapshot.exists) {
          // Navigate to the next page if the code exists
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientCarePage(patientId: code),
            ),
          );
        } else {
          // Show an error message if the code does not exist
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppStrings.invalidPatientId)));
        }
      } catch (e) {
        // Show an error message in case of a Firebase issue
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${AppStrings.error}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.enterPatientCode)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Field to enter the patient code
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: AppStrings.patientId,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.pleaseEnterPatientCode;
                  }
                  if (value.length != 9) {
                    return AppStrings.patientCodeSizeIncorrect;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Button to submit the code
              ElevatedButton(
                onPressed: () => _submitCode(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(AppStrings.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

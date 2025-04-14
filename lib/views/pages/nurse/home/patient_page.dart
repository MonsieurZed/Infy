import 'package:flutter/material.dart';
import 'package:infy/data/strings.dart';
import 'package:provider/provider.dart';
import 'package:infy/data/providers/patient_provider.dart';
import 'package:infy/views/pages/nurse/patient/add_edit_patient_page.dart';
import 'package:infy/views/pages/nurse/patient/show_patient_page.dart';
import 'package:infy/views/widgets/patient_widget.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({super.key});

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      Provider.of<PatientProvider>(
        context,
        listen: false,
      ).filterPatients(_searchController.text);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<PatientProvider>(
          context,
          listen: false,
        ).fetchMorePatients();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final patients = patientProvider.filteredPatients;
    final isLoading = patientProvider.isLoading;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: AppStrings.searchbarPatient,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  // Add patient button
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddPatientPage(),
                          ),
                        ).then((_) {
                          // Refresh the list after returning
                          patientProvider.fetchPatients(reload: true);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Slightly rounded corners
                        ),
                        padding: const EdgeInsets.all(
                          4,
                        ), // Ensures a square shape
                      ),
                      child: Icon(Icons.add, size: 48, color: Colors.teal[200]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: patients.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < patients.length) {
                    final patient = patients[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ShowPatientPage(patient: patient),
                          ),
                        ).then((_) {
                          // Refresh the list after returning
                          patientProvider.fetchPatients(reload: true);
                        });
                      },
                      child: PatientWidget(patient: patient),
                    );
                  } else {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

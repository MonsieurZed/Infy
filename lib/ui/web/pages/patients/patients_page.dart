import 'package:flutter/material.dart';
import 'package:infy/class/patient_class.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/providers/patient_provider.dart';
import 'package:infy/ui/web/pages/patients/widgets/patient_detail_form.dart';
import 'package:infy/ui/web/pages/patients/widgets/patient_list_sidebar.dart';
import 'package:provider/provider.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({Key? key}) : super(key: key);

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  Patient? _selectedPatient;
  bool _isCreatingNewPatient = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Barre latérale avec la liste des patients
          PatientListSidebar(
            selectedPatient: _selectedPatient,
            onPatientSelected: (patient) {
              setState(() {
                if (patient.documentId.isEmpty) {
                  // Nouveau patient
                  _isCreatingNewPatient = true;
                } else {
                  _isCreatingNewPatient = false;
                }
                _selectedPatient = patient;
              });
            },
          ),

          // Zone principale divisée avec le formulaire de détails réduit en haut à gauche
          Expanded(
            child:
                _selectedPatient != null
                    ? Stack(
                      children: [
                        // Arrière-plan
                        Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.1),
                        ),

                        // En-tête de la page
                        Positioned(
                          top: 24,
                          left: 24,
                          right: 24,
                          child: _buildPatientHeader(),
                        ),

                        // Formulaire de détails en haut à gauche (1/4 de l'espace)
                        Positioned(
                          top: 100,
                          left: 24,
                          width: MediaQuery.of(context).size.width * 0.25,
                          bottom: 24,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: PatientDetailForm(
                              patient: _selectedPatient!,
                              isNewPatient: _isCreatingNewPatient,
                              onSave: _handleSavePatient,
                            ),
                          ),
                        ),

                        // Espace pour d'autres contenus (statistiques, historique, etc.)
                        Positioned(
                          top: 100,
                          left:
                              24 +
                              MediaQuery.of(context).size.width * 0.25 +
                              24, // Décalé après le formulaire + marge
                          right: 24,
                          bottom: 24,
                          child: _buildAdditionalContent(),
                        ),
                      ],
                    )
                    : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    if (_selectedPatient == null) return const SizedBox.shrink();

    return Row(
      children: [
        Text(
          _isCreatingNewPatient
              ? AppStrings.addNewPatient
              : '${_selectedPatient!.firstName} ${_selectedPatient!.lastName}',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (!_isCreatingNewPatient)
          ElevatedButton.icon(
            icon: const Icon(Icons.history),
            label: Text(AppStrings.viewHistory),
            onPressed: () {
              // Action pour voir l'historique
            },
          ),
      ],
    );
  }

  Widget _buildAdditionalContent() {
    // Zone pour afficher d'autres informations utiles comme les statistiques,
    // l'historique des soins, etc.
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        _buildInfoCard(
          Icons.calendar_month_outlined,
          'Rendez-vous',
          'Prochain rendez-vous: 25 avril 2025',
          Colors.blue,
        ),
        _buildInfoCard(
          Icons.medication_outlined,
          'Traitements en cours',
          '2 traitements actifs',
          Colors.green,
        ),
        _buildInfoCard(
          Icons.medical_services_outlined,
          'Derniers soins',
          'Dernier soin: 15 avril 2025',
          Colors.orange,
        ),
        _buildInfoCard(
          Icons.analytics_outlined,
          'Statistiques',
          '12 visites au total',
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: color),
                  onPressed: () {},
                  tooltip: 'Voir plus',
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.selectPatient,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.selectPatientDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(AppStrings.addNewPatient),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              setState(() {
                _selectedPatient = Patient.empty();
                _isCreatingNewPatient = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleSavePatient(Patient patient) async {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    await patientProvider.submit(patient);

    if (mounted) {
      setState(() {
        _selectedPatient = patient;
        _isCreatingNewPatient = false;
      });
    }
  }
}

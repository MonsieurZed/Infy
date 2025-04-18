import 'package:flutter/material.dart';
import 'package:infy/class/patient_class.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/providers/patient_provider.dart';
import 'package:provider/provider.dart';

class PatientListSidebar extends StatefulWidget {
  final Patient? selectedPatient;
  final Function(Patient) onPatientSelected;

  const PatientListSidebar({
    Key? key,
    this.selectedPatient,
    required this.onPatientSelected,
  }) : super(key: key);

  @override
  State<PatientListSidebar> createState() => _PatientListSidebarState();
}

class _PatientListSidebarState extends State<PatientListSidebar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _loadPatients() async {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    setState(() {
      _isLoading = true;
    });

    try {
      await patientProvider.fetchPatients();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.surfaceVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          _buildSearchBar(),
          Expanded(child: _buildPatientList()),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.surfaceVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.patients,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.searchbarPatient,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPatientList() {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, _) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final patients = patientProvider.patients;

        if (patients.isEmpty) {
          return _buildEmptyPatientList();
        }

        // Convert Map to List and then filter the patients by search query
        List<Patient> filteredPatients =
            patients.values.where((patient) {
              final fullName =
                  '${patient.firstName} ${patient.lastName}'.toLowerCase();
              return _searchQuery.isEmpty ||
                  fullName.contains(_searchQuery.toLowerCase());
            }).toList();

        if (filteredPatients.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.noResults,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredPatients.length + 1, // +1 pour le bouton Add
          itemBuilder: (context, index) {
            // Ajouter un nouvel élément à la fin
            if (index == filteredPatients.length) {
              return _buildAddPatientButton();
            }

            final patient = filteredPatients[index];
            final isSelected =
                widget.selectedPatient?.documentId == patient.documentId;

            return _buildPatientListItem(patient, isSelected);
          },
        );
      },
    );
  }

  Widget _buildPatientListItem(Patient patient, bool isSelected) {
    // Get safe initials even if names are empty
    final String firstInitial =
        patient.firstName.isNotEmpty ? patient.firstName[0] : '?';
    final String lastInitial =
        patient.lastName.isNotEmpty ? patient.lastName[0] : '?';
    final String initials = '$firstInitial$lastInitial';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            initials,
            style: TextStyle(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${patient.firstName} ${patient.lastName}',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${DateTime.now().year - patient.dob.year} ${AppStrings.years}',
          style: TextStyle(
            color:
                isSelected
                    ? Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withOpacity(0.7)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        onTap: () => widget.onPatientSelected(patient),
      ),
    );
  }

  Widget _buildEmptyPatientList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noPatients,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(AppStrings.addNewPatient),
            onPressed: () {
              widget.onPatientSelected(Patient.empty());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddPatientButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.add),
        label: Text(AppStrings.addNewPatient),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          widget.onPatientSelected(Patient.empty());
        },
      ),
    );
  }
}

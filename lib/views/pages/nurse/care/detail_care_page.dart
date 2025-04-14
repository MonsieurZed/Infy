import 'package:flutter/material.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/providers/care_provider.dart';
import 'package:infy/utils/app_logger.dart';
import 'package:intl/intl.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:infy/views/pages/nurse/care/add_edit_care_page.dart';
import 'package:provider/provider.dart';
import 'package:infy/data/strings.dart';

class DetailCarePage extends StatefulWidget {
  final Care care;
  final Patient patient;

  const DetailCarePage({super.key, required this.care, required this.patient});

  @override
  State<DetailCarePage> createState() => _DetailCarePageState();
}

class _DetailCarePageState extends State<DetailCarePage> {
  Future<void> _deleteCare(BuildContext context) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text(AppStrings.confirmDeletionTitle),
              content: const Text(AppStrings.confirmDeletionMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(AppStrings.cancelButton),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(AppStrings.deleteButton),
                ),
              ],
            ),
      );

      if (confirm == true) {
        final careProvider = Provider.of<CareProvider>(context, listen: false);

        await careProvider.deleteCare(
          care: widget.care,
          patient: widget.patient,
        );

        AppLogger.snackbar(context, AppStrings.careDeletedSuccessfully);

        Navigator.pop(context);
      } // Retour à la page précédente après suppression
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _editCare(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AddEditCarePage(patient: widget.patient, care: widget.care),
      ),
    );
    if (result == true) {
      // Recharger les données
      Provider.of<CareProvider>(
        context,
        listen: false,
      ).fetchById(widget.care.documentId, reload: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.careDetailsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editCare(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteCare(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nom du patient
                  const Text(
                    AppStrings.patientLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.patient.firstName} ${widget.patient.lastName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date et heure du soin
                  const Text(
                    AppStrings.dateTimeLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      AppConstants.fullTimeFormat,
                      AppConstants.locale,
                    ).format(widget.care.timestamp.toDate()),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Annotation
                  if (widget.care.info != null && widget.care.info!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          AppStrings.annotationLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.care.info!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  // Liste des soins réalisés
                  if (widget.care.performed.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          AppStrings.carePerformedLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children:
                              widget.care.performed
                                  .map(
                                    (soin) => Chip(
                                      label: Text(soin),
                                      backgroundColor: Colors.teal.shade100,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // Images
                  if (widget.care.images.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          AppStrings.images,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children:
                              widget.care.images.entries.map((entry) {
                                final url = entry.key;
                                return GestureDetector(
                                  onTap: () {
                                    // Affiche l'URL de l'image dans une boîte de dialogue
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            content: Image.network(
                                              entry.value,
                                              fit: BoxFit.cover,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text('Fermer'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      url,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

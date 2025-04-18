// Removed unused imports and organized the remaining ones
import 'package:flutter/material.dart';
import 'package:infy/class/care_class.dart';
import 'package:infy/class/patient_class.dart';
import 'package:infy/contants/constants.dart';
import 'package:infy/providers/care_provider.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/utils/app_logger.dart';
import 'package:infy/ui/mobile/pages/caregivers/care/care_addedit_page.dart';
import 'package:infy/ui/mobile/pages/caregivers/widget/care_chip.dart';
import 'package:infy/ui/mobile/widgets/image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailCarePage extends StatefulWidget {
  final String careId;
  final Patient patient;

  const DetailCarePage({
    super.key,
    required this.careId,
    required this.patient,
  });

  @override
  State<DetailCarePage> createState() => _DetailCarePageState();
}

class _DetailCarePageState extends State<DetailCarePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Chargement initial du soin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCare();
    });
  }

  Future<void> _loadCare() async {
    try {
      await Provider.of<CareProvider>(
        context,
        listen: false,
      ).fetchById(widget.careId);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorFetchingItem}: $e')),
      );
    }
  }

  Future<void> _deleteCare(BuildContext context, Care care) async {
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

        await careProvider.deleteCare(care: care, patient: widget.patient);

        AppLogger.snackbar(context, AppStrings.careDeletedSuccessfully);

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _editCare(BuildContext context, Care care) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddEditCarePage(patient: widget.patient, care: care),
      ),
    );
    if (result == true) {
      // Recharger les données
      setState(() {
        _isLoading = true;
      });
      await Provider.of<CareProvider>(
        context,
        listen: false,
      ).fetchById(widget.careId);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CareProvider>(
      builder: (context, careProvider, child) {
        final care = careProvider.cares[widget.careId];

        if (_isLoading || care == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(AppStrings.careDetailsTitle),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.careDetailsTitle),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editCare(context, care),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteCare(context, care),
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
                      Text(
                        AppStrings.patientLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.patient.firstName} ${widget.patient.lastName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date et heure du soin
                      Text(
                        AppStrings.dateTimeLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          AppConstants.fullTimeFormat,
                          AppConstants.locale,
                        ).format(care.timestamp.toDate()),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Annotation
                      if (care.info != null && care.info!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppStrings.annotationLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiary.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              care.info!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      // Liste des soins réalisés
                      if (care.performed.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppStrings.carePerformedLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiary.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children:
                                  care.performed
                                      .map((soin) => ChipCareWidget(text: soin))
                                      .toList(),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      // Images
                      if (care.images.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppStrings.images,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiary.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(care.images.length, (
                                index,
                              ) {
                                final thumbnailUrl = care.images.keys.elementAt(
                                  index,
                                );
                                return GestureDetector(
                                  onTap: () {
                                    // Ouvre le visualiseur d'image plein écran
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ImageViewer(
                                              imageUrls:
                                                  care.images.values.toList(),
                                              initialIndex: index,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'image_$index',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        thumbnailUrl,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Container(
                                            height: 100,
                                            width: 100,
                                            color: Colors.grey[300],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            height: 100,
                                            width: 100,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.broken_image,
                                              size: 40,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }),
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
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/contants/constants.dart';
import 'package:infy/data/contants/style.dart';
import 'package:infy/views/pages/caregivers/widget/care_chip.dart';
import 'package:infy/views/pages/caregivers/care/care_detail_page.dart';
import 'package:infy/views/widgets/image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:infy/data/class/patient_class.dart';

class CareCard extends StatelessWidget {
  const CareCard({
    super.key,
    required this.care,
    this.patient,
    this.patientId,
    this.showPatientName = false,
    this.onTap,
  }) : assert(
         (patient != null || patientId != null) || !showPatientName,
         'Either patient or patientId must be provided when showPatientName is true',
       );

  final Care care;
  final Patient? patient;
  final String? patientId;
  final bool showPatientName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            if (patient != null || patientId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DetailCarePage(
                        careId: care.documentId,
                        patient:
                            patient ??
                            Patient(
                              documentId: patientId!,
                              firstName: '',
                              lastName: '',
                              address: null,
                              dob: DateTime.now(),
                              caregivers: const [],
                            ),
                      ),
                ),
              );
            }
          },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date, heure et nom du patient (si demandé)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat(
                          AppConstants.hourTimeFormat,
                        ).format(care.timestamp.toDate()),
                        style: KTextStylesCustom.descBasic,
                      ),
                    ],
                  ),
                  // Patient's name (optionnel)
                  if (showPatientName && patient != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${patient!.firstName} ${patient!.lastName}',
                          style: KTextStylesCustom.descBasic,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Annotation
              if (care.info != null && care.info!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(care.info!, style: KTextStylesCustom.descBasic),
                    const SizedBox(height: 8),
                  ],
                ),
              // Liste des soins réalisés
              if (care.performed.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 2.0,
                      runSpacing: 2.0,
                      children:
                          care.performed
                              .map((careItem) => ChipCareWidget(text: careItem))
                              .toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              // Images avec aperçu et accès à ImageViewer
              if (care.images.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.image,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          care.images.length.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (care.images.isNotEmpty)
                      SizedBox(
                        height: 60,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: care.images.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final thumbnailUrl = care.images.keys.elementAt(
                              index,
                            );
                            return GestureDetector(
                              onTap: () {
                                // Ouvrir l'ImageViewer avec toutes les images
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
                                tag: 'care_image_${care.documentId}_$index',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    thumbnailUrl,
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

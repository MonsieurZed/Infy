import 'package:flutter/material.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/constants.dart';
import 'package:intl/intl.dart';
import 'package:infy/data/class/patient_class.dart';

class CareSummaryWidget extends StatelessWidget {
  const CareSummaryWidget({
    super.key,
    required this.care,
    required this.patient,
  });

  final Care care;
  final Patient patient;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and time of care
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        AppConstants.hourTimeFormat,
                      ).format(care.timestamp.toDate()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Patient's name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${patient.firstName} ${patient.lastName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
                  const SizedBox(height: 4),
                  Text(
                    care.info!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            // List of completed care
            if (care.performed.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    children:
                        care.performed
                            .map(
                              (careItem) => Chip(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 0,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                label: Text(careItem),
                                backgroundColor: Colors.teal.shade100,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            // Number of images
            if (care.images.isNotEmpty)
              Row(
                children: [
                  const Icon(
                    Icons.image, // Icône d'image
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 4,
                  ), // Espacement entre l'icône et le texte
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
          ],
        ),
      ),
    );
  }
}

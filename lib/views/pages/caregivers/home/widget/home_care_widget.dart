import 'package:flutter/material.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/contants/constants.dart';
import 'package:infy/views/pages/caregivers/widget/care_chip.dart';
import 'package:intl/intl.dart';
import 'package:infy/data/class/patient_class.dart';

class HomeCareWidget extends StatelessWidget {
  const HomeCareWidget({super.key, required this.care, required this.patient});

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
                            .map((careItem) => ChipCareWidget(text: careItem))
                            .toList(),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            // Number of images
            if (care.images.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.image, // Icône d'image
                    color: Theme.of(context).colorScheme.primary,
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

import 'package:flutter/material.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/constants.dart';
import 'package:intl/intl.dart';
import 'package:infy/data/strings.dart';

class PatientCareWidget extends StatelessWidget {
  const PatientCareWidget({
    super.key,
    required this.care,
    required this.caregiverName,
  });

  final Care care;
  final String caregiverName;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line 1: Date and time
            Text(
              DateFormat(
                AppConstants.fullTimeFormat,
                AppConstants.locale,
              ).format(care.timestamp.toDate()),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Line 2: Caregiver's name
            Text(caregiverName, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 8),
            // Line 3: Annotation
            if (care.info != null && care.info!.isNotEmpty)
              Text(
                care.info!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            const SizedBox(height: 8),
            // Line 4: List of completed care
            if (care.carePerformed.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.careDetailsTitle,
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
                        care.carePerformed
                            .map(
                              (careItem) => Chip(
                                label: Text(careItem),
                                backgroundColor: Colors.teal.shade100,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

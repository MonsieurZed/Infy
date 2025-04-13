import 'package:flutter/material.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/strings.dart';
import 'package:infy/data/style.dart';
import 'package:intl/intl.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/views/pages/nurse/care/detail_care_page.dart';
import 'package:infy/data/class/patient_class.dart';

class CareWidget extends StatelessWidget {
  const CareWidget({super.key, required this.care, required this.patient});

  final Care care;
  final Patient patient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailCarePage(care: care, patient: patient),
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Date et heure
                Text(
                  DateFormat(
                    AppConstants.fullTimeFormat,
                    AppConstants.locale,
                  ).format(care.timestamp.toDate()),
                  style: KTextStylesCustom.descBasic,
                ),
                const SizedBox(height: 8),
                // Annotation
                if (care.info != null && care.info!.isNotEmpty)
                  Text(care.info!, style: KTextStylesCustom.descBasic),
                const SizedBox(height: 8),
                // Soins réalisés
                if (care.performed.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            care.performed
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
                const SizedBox(height: 8),
                // Images
                if (care.images != null && care.images!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            care.images.entries.map((entry) {
                              return GestureDetector(
                                onTap: () {
                                  // Affiche l'URL de l'image dans une boîte de dialogue
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          content: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            child: Image.network(
                                              entry.value,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Fermer'),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    entry.key,
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
    );
  }
}

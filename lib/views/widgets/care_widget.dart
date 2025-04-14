import 'package:flutter/material.dart';
import 'package:infy/data/constants.dart';
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
                // Date et heure
                Text(
                  DateFormat(
                    AppConstants.fullTimeFormat,
                    AppConstants.locale,
                  ).format(care.timestamp.toDate()),
                  style: KTextStylesCustom.descBasic,
                ),
                // Annotation
                if (care.info != null && care.info!.isNotEmpty)
                  Text(care.info!, style: KTextStylesCustom.descBasic),
                // Soins réalisés
                if (care.performed.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 2.0,
                        runSpacing: 2.0,
                        children:
                            care.performed
                                .map(
                                  (careItem) => Chip(
                                    padding: const EdgeInsets.all(0.0),
                                    label: Text(careItem),
                                    backgroundColor: Colors.teal.shade100,
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                // Images
                if (care.images.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children:
                            care.images.entries.map((entry) {
                              return GestureDetector(
                                onTap: () {
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
                                    height: 60,
                                    width: 60,
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

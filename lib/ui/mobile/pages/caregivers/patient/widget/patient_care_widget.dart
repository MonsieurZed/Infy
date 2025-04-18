import 'package:flutter/material.dart';
import 'package:infy/contants/constants.dart';
import 'package:infy/contants/style.dart';
import 'package:infy/ui/mobile/pages/caregivers/widget/care_chip.dart';
import 'package:intl/intl.dart';
import 'package:infy/class/care_class.dart';
import 'package:infy/ui/mobile/pages/caregivers/care/care_detail_page.dart';
import 'package:infy/class/patient_class.dart';

class PatientCareWidget extends StatelessWidget {
  const PatientCareWidget({
    super.key,
    required this.care,
    this.patient,
    this.patientId,
  }) : assert(
         patient != null || patientId != null,
         'Either patient or patientId must be provided',
       );

  final Care care;
  final Patient? patient;
  final String? patientId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                                  (careItem) => ChipCareWidget(text: careItem),
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

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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Line 3: Date and time
                Text(
                  DateFormat(
                    AppConstants.fullTimeFormat,
                    AppConstants.locale,
                  ).format(care.timestamp.toDate()),
                  style: KTextStylesCustom.descBasic,
                ),
                const SizedBox(height: 8),
                // Line 4: Annotation
                if (care.info != null)
                  Text(care.info ?? '', style: KTextStylesCustom.descBasic),
                const SizedBox(height: 8),
                if (care.carePerformed.isNotEmpty)
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
        ),
      ),
    );
  }
}

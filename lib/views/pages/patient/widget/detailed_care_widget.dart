import 'package:flutter/material.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/contants/constants.dart';
import 'package:infy/data/contants/strings.dart';
import 'package:intl/intl.dart';

class DetailedCareWidget extends StatefulWidget {
  const DetailedCareWidget({
    super.key,
    required this.care,
    required this.caregiverName,
  });

  final Care care;
  final String caregiverName;

  @override
  State<DetailedCareWidget> createState() => _DetailedCareWidgetState();
}

class _DetailedCareWidgetState extends State<DetailedCareWidget> {
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
              ).format(widget.care.timestamp.toDate()),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primaryFixedDim,
              ),
            ),
            const SizedBox(height: 8),
            // Line 2: Caregiver's name
            Text(widget.caregiverName, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 8),
            // Line 3: Annotation
            if (widget.care.info != null && widget.care.info!.isNotEmpty)
              Text(
                widget.care.info!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primaryFixedDim,
                ),
              ),
            const SizedBox(height: 8),
            // Line 4: List of completed care
            if (widget.care.performed.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.careDetailsTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primaryFixedDim,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children:
                        widget.care.performed
                            .map(
                              (careItem) => Chip(
                                label: Text(careItem),
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
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

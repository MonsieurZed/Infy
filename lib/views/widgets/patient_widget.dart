import 'package:flutter/material.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:infy/data/strings.dart';
import 'package:infy/data/style.dart';
import 'package:infy/views/pages/nurse/care/add_edit_care_page.dart';
import 'package:infy/views/pages/nurse/patient/add_edit_patient_page.dart'; // Import for the add care page
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs

class PatientWidget extends StatefulWidget {
  const PatientWidget({super.key, required this.patient});

  final Patient patient;

  @override
  State<PatientWidget> createState() => _PatientWidgetState();
}

class _PatientWidgetState extends State<PatientWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align widgets at the top
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space out the columns
            children: [
              // First column aligned to the right
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align to the right
                  children: [
                    Text(
                      '${widget.patient.firstName} ${widget.patient.lastName}',
                      style: KTextStylesCustom.titleTeal,
                    ),
                    Text(
                      '${DateTime.now().year - widget.patient.dob.year}'
                      ' - '
                      '${widget.patient.dob.day.toString().padLeft(2, '0')}/'
                      '${widget.patient.dob.month.toString().padLeft(2, '0')}/'
                      '${widget.patient.dob.year}',
                      style: KTextStylesCustom.descBasic,
                    ),
                    Text(
                      widget.patient.address ?? AppStrings.addressNotAvailable,
                      style: KTextStylesCustom.descBasic,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20), // Spacing between columns
              // Second column aligned to the left
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align to the left
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddPatientPage(
                                patient: widget.patient, // Pass the patient ID
                              ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.teal),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddEditCarePage(
                                patient: widget.patient, // Pass the patient ID
                              ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_box, color: Colors.teal),
                  ),
                  IconButton(
                    onPressed: () async {
                      final address = widget.patient.address;
                      if (address != null) {
                        final Uri uri = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Impossible d\'ouvrir l\'application de navigation.',
                              ),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Adresse non disponible.'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.navigation, color: Colors.teal),
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

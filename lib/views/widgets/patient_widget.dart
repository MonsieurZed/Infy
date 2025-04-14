import 'package:flutter/material.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:infy/data/strings.dart';
import 'package:infy/data/style.dart';
import 'package:infy/views/pages/nurse/care/add_edit_care_page.dart';

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
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center items vertically
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space out the columns
            children: [
              // First column aligned to the left
              Expanded(
                flex: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '${widget.patient.firstName} ${widget.patient.lastName}',
                        style: KTextStylesCustom.titleTeal,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8.0),

                      child: Text(
                        '${DateTime.now().year - widget.patient.dob.year}'
                        ' - '
                        '${widget.patient.dob.day.toString().padLeft(2, '0')}/'
                        '${widget.patient.dob.month.toString().padLeft(2, '0')}/'
                        '${widget.patient.dob.year}',
                        style: KTextStylesCustom.descBasic,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        widget.patient.address ??
                            AppStrings.addressNotAvailable,
                        style: KTextStylesCustom.descBasic,
                      ),
                    ),
                  ],
                ),
              ),
              // Vertical bar
              Container(
                width: 1,
                height: 100,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
              // Second column with the button aligned to the right
              Container(
                alignment: Alignment.center,
                child: IconButton(
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
                  icon: Icon(Icons.add, color: Colors.teal[200]),
                  iconSize: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

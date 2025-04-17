import 'package:flutter/material.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/contants/constants.dart';
import 'package:infy/data/providers/patient_provider.dart';
import 'package:infy/data/contants/strings.dart';
import 'package:intl/intl.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:infy/views/widgets/care_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:infy/data/providers/care_provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // For initializeDateFormatting
import 'package:infy/views/pages/caregivers/care/care_detail_page.dart';

class CarePage extends StatefulWidget {
  const CarePage({super.key});

  @override
  State<CarePage> createState() => _CarePageState();
}

class _CarePageState extends State<CarePage> {
  final ScrollController _scrollController =
      ScrollController(); // Adding the ScrollController
  DateTime actualdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeDateFormatting(
        'fr_FR',
        null,
      ); // Initialization for French localization
      Provider.of<CareProvider>(
        context,
        listen: false,
      ).fetchByDate(actualdate).then((_) {
        _jumpToBottom(); // Scroll to the bottom after data is loaded
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Release the ScrollController
    super.dispose();
  }

  void changeDate(int days) {
    setState(() {
      actualdate = actualdate.add(Duration(days: days));
      Provider.of<CareProvider>(
        context,
        listen: false,
      ).fetchByDate(actualdate).then((_) {
        _jumpToBottom(); // Scroll to the bottom after date change
      });
    });
  }

  void _jumpToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      ); // Immediate scroll
    }
  }

  @override
  Widget build(BuildContext context) {
    final careProvider = Provider.of<CareProvider>(context);
    final patientProvider = Provider.of<PatientProvider>(context);
    final Map<String, Care> careSummaries = careProvider.cares;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Date Picker Row
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => changeDate(-1),
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: actualdate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          actualdate = pickedDate;
                          careProvider.fetchByDate(actualdate);
                        });
                      }
                    },
                    child: Text(
                      DateFormat(
                        AppConstants.fullTimeFormat,
                        AppConstants.locale,
                      ).format(actualdate),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed:
                      actualdate.day == DateTime.now().day
                          ? null
                          : () => changeDate(1),
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Care Summaries List
            Expanded(
              child:
                  careProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : careSummaries.isEmpty
                      ? const Center(child: Text(AppStrings.noCareFound))
                      : Builder(
                        builder: (context) {
                          final filteredCareSummaries =
                              careSummaries.values
                                  .where(
                                    (care) =>
                                        care.timestamp.toDate().year ==
                                            actualdate.year &&
                                        care.timestamp.toDate().month ==
                                            actualdate.month &&
                                        care.timestamp.toDate().day ==
                                            actualdate.day,
                                  )
                                  .toList();

                          if (filteredCareSummaries.isEmpty) {
                            return const Center(
                              child: Text(AppStrings.noCareFound),
                            );
                          }

                          return ListView.builder(
                            controller: _scrollController,
                            physics: const ClampingScrollPhysics(),
                            itemCount: filteredCareSummaries.length,
                            itemBuilder: (context, index) {
                              final care = filteredCareSummaries[index];
                              return FutureBuilder<Patient?>(
                                future: patientProvider.fetchPatientById(
                                  care.patientId,
                                ),
                                builder: (context, patientSnapshot) {
                                  if (patientSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox.shrink();
                                  } else if (patientSnapshot.hasError) {
                                    return const Center(
                                      child: Text(AppStrings.error),
                                    );
                                  } else {
                                    final patient = patientSnapshot.data;
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
                                                      Patient.empty(),
                                                ),
                                          ),
                                        );
                                      },
                                      child: CareCard(
                                        care: care,
                                        patient: patient ?? Patient.empty(),
                                        showPatientName: true,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

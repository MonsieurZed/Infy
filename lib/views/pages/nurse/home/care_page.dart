import 'package:flutter/material.dart';
import 'package:infy/data/class/care_class.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/strings.dart';
import 'package:intl/intl.dart';
import 'package:infy/data/class/patient_class.dart';
import 'package:infy/views/widgets/care_summary_widget.dart';
import 'package:provider/provider.dart';
import 'package:infy/data/providers/care_provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // For initializeDateFormatting
import 'package:infy/views/pages/nurse/care/detail_care_page.dart';

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
      ).fetchCareByDate(actualdate).then((_) {
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
      ).fetchCareByDate(actualdate).then((_) {
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
    final Map<Care, Patient> careSummaries =
        careProvider.careSummariesByDate[actualdate] ?? {};

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
                          careProvider.fetchCareByDate(actualdate);
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
                  onPressed: () => changeDate(1),
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
                      : ListView.builder(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        itemCount: careSummaries.length,
                        itemBuilder: (context, index) {
                          final care =
                              careSummaries.entries.elementAt(index).key;
                          final patient =
                              careSummaries.entries.elementAt(index).value;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DetailCarePage(
                                        care: care,
                                        patient: patient,
                                      ),
                                ),
                              );
                            },
                            child: CareSummaryWidget(
                              care: care,
                              patient: patient,
                            ),
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

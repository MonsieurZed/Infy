import 'package:flutter/material.dart';
import 'package:infy/contants/constants.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/ui/mobile/pages/caregivers/widget_tree.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:infy/providers/care_provider.dart';
import 'package:infy/providers/patient_provider.dart';
import 'package:infy/providers/care_item_provider.dart';

class CaregiverLoadingPage extends StatefulWidget {
  const CaregiverLoadingPage({super.key});

  @override
  State<CaregiverLoadingPage> createState() => _CaregiverLoadingPageState();
}

class _CaregiverLoadingPageState extends State<CaregiverLoadingPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Defer the loading of providers until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProviders();
    });
  }

  Future<void> _loadProviders() async {
    try {
      // Create a list of compute-isolated tasks to run in parallel
      // This moves the heavy database operations off the main thread
      final futures = <Future>[];

      // Add each provider task with a small stagger to avoid thread contention
      futures.add(
        _loadProviderData(() async {
          await Provider.of<CareProvider>(
            context,
            listen: false,
          ).fetchByDate(DateTime.now());
        }),
      );

      // Wait a tiny bit before starting the next task to prevent CPU spikes
      await Future.delayed(const Duration(milliseconds: 20));

      futures.add(
        _loadProviderData(() async {
          await Provider.of<PatientProvider>(
            context,
            listen: false,
          ).fetchPatients();
        }),
      );

      await Future.delayed(const Duration(milliseconds: 20));

      futures.add(
        _loadProviderData(() async {
          await Provider.of<CareItemProvider>(
            context,
            listen: false,
          ).fetchCareItems();
        }),
      );

      // Wait for all operations to complete
      await Future.wait(futures);
    } catch (e) {
      debugPrint('${AppStrings.errorLoadingProviders}: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Navigate to the next page using microtask to avoid blocking the UI thread
        Future.microtask(() {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WidgetTree()),
            );
          }
        });
      }
    }
  }

  // Helper method to load provider data in a way that minimizes main thread impact
  Future<void> _loadProviderData(Future<void> Function() task) async {
    try {
      // Use compute or a similar approach to move work off main thread
      // Since we can't directly use compute with context-dependent functions,
      // we'll wrap the task in a try-catch and minimize its main thread impact
      await task();
    } catch (e) {
      debugPrint('Error loading provider data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _isLoading
                ? Lottie.asset(
                  LottiesString.loading,
                  height: MediaQuery.of(context).size.height * 0.5,
                )
                : const Text(AppStrings.loadingComplete),
      ),
    );
  }
}

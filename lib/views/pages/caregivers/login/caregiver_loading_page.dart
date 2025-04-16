import 'package:flutter/material.dart';
import 'package:infy/data/contants/constants.dart';
import 'package:infy/data/contants/strings.dart';
import 'package:infy/views/pages/caregivers/widget_tree.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:infy/data/providers/care_provider.dart';
import 'package:infy/data/providers/patient_provider.dart';
import 'package:infy/data/providers/care_item_provider.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
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
      // Fetch data from all providers
      await Future.wait([
        Provider.of<CareProvider>(
          context,
          listen: false,
        ).fetchByDate(DateTime.now()),
        Provider.of<PatientProvider>(context, listen: false).fetchPatients(),
        Provider.of<CareItemProvider>(context, listen: false).fetchCareItems(),
      ]);
    } catch (e) {
      debugPrint('${AppStrings.errorLoadingProviders}: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });

      // Navigate to the next page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WidgetTree()),
        );
      }
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

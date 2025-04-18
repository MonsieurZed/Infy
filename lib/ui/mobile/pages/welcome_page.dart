import 'package:flutter/material.dart';
import 'package:infy/contants/constants.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/ui/mobile/pages/caregivers/login/caregiver_login_page.dart';
import 'package:infy/ui/mobile/pages/patient/login_page.dart';
import 'package:infy/ui/mobile/widgets/logo_hero_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infy/ui/mobile/pages/caregivers/widget_tree.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _checkLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(PrefsString.isLoggedIn) ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WidgetTree()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLogin(context);
    });

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FractionallySizedBox(
                widthFactor: constraints.minWidth > 500 ? .5 : 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LogoHeroWidget(),
                    const SizedBox(height: 40),
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text(AppStrings.caregiverButton),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPatientPage(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: const Text(AppStrings.patientButton),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

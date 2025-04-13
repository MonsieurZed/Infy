import 'package:flutter/material.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/views/pages/nurse/login/login_page.dart';
import 'package:infy/views/pages/patient/login_page.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infy/views/pages/nurse/widget_tree.dart';
import 'package:infy/data/strings.dart';

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
    _checkLogin(context);

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
                    Lottie.asset(
                      LottiesString.home,
                      height: MediaQuery.of(context).size.height * 0.5,
                    ),
                    SizedBox(height: 40),
                    FittedBox(
                      child: Text(
                        AppStrings.welcomeMessage,
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LoginPage();
                            },
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                      ),
                      child: Text(AppStrings.caregiverButton),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LoginPatientPage();
                            },
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                      ),
                      child: Text(AppStrings.patientButton),
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

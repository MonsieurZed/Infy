import 'package:flutter/material.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/notifiers.dart';
import 'package:infy/views/pages/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infy/data/strings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: isDarkModeNotifier,
                builder: (context, value, child) {
                  return SwitchListTile.adaptive(
                    title: const Text(AppStrings.darkModeToggle),
                    value: isDarkModeNotifier.value,
                    onChanged: (value) async {
                      isDarkModeNotifier.value = !isDarkModeNotifier.value;
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool(
                        PrefsString.themeModeKey,
                        isDarkModeNotifier.value,
                      );
                    },
                  );
                },
              ),

              ListTile(
                title: Text(AppStrings.logoutButton),
                onTap: () {
                  selectedPageNotifier.value = 1;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return WelcomePage();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/notifiers.dart';
import 'package:infy/firebase_options.dart';
import 'package:infy/views/pages/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'data/providers/care_provider.dart';
import 'data/providers/patient_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:infy/data/providers/care_item_provider.dart';
import 'data/strings.dart';

// Ensure Workmanager is initialized correctly

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(AppConstants.locale, null);
  // Check if Firebase is already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Lock to portrait mode
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CareProvider()),
          ChangeNotifierProvider(
            create: (_) => PatientProvider(),
          ), // Ajouter PatientProvider
          ChangeNotifierProvider(
            create: (_) => CareItemProvider(),
          ), // Ajouter CareItemProvider
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initThemeMode();
  }

  void initThemeMode() async {
    isDarkModeNotifier.value = false;
    // Load the theme mode from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isDarkMode = prefs.getBool(PrefsString.themeModeKey);
    if (isDarkMode != null) isDarkModeNotifier.value = isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (BuildContext context, dynamic value, Widget? child) {
        return MaterialApp(
          title: AppStrings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness:
                  isDarkModeNotifier.value ? Brightness.dark : Brightness.light,
            ),
          ),
          home: MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return WelcomePage();
  }
}

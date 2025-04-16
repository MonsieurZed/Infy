import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infy/data/contants/constants.dart';
import 'package:infy/data/providers/user_provider.dart';
import 'package:infy/firebase_options.dart';
import 'package:infy/views/pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'data/providers/care_provider.dart';
import 'data/providers/patient_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:infy/data/providers/care_item_provider.dart';
import 'data/contants/strings.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:infy/data/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );

  await initializeDateFormatting(AppConstants.locale, null);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) async {
    FlutterNativeSplash.remove();
    ThemeMode themeMode = await ThemeService.getThemeMode();
    // Initialiser le notificateur avec le thème actuel
    themeModeNotifier.value = themeMode;
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CareProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => CareItemProvider()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, themeMode, child) {
          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: ThemeService.getLightTheme(),
            darkTheme: ThemeService.getDarkTheme(),
            themeMode: themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

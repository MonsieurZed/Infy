import 'package:flutter/material.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/providers/care_item_provider.dart';
import 'package:infy/providers/care_provider.dart';
import 'package:infy/providers/image_cache_provider.dart';
import 'package:infy/providers/patient_provider.dart';
import 'package:infy/providers/user_provider.dart';
import 'package:infy/services/theme_service.dart';
import 'package:infy/ui/web/pages/auth/login_page.dart';
import 'package:infy/ui/web/pages/dashboard/dashboard_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class WebApp extends StatefulWidget {
  const WebApp({super.key});

  @override
  State<WebApp> createState() => _WebAppState();
}

class _WebAppState extends State<WebApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CareProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => CareItemProvider()),
        ChangeNotifierProvider(create: (_) => ImageCacheProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeService.getLightTheme(),
        darkTheme: ThemeService.getDarkTheme(),
        themeMode: ThemeMode.system,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const DashboardPage();
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}

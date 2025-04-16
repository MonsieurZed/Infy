import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:infy/data/contants/constants.dart';
import 'package:infy/data/utils/general_notifiers.dart';
import 'package:infy/views/pages/caregivers/home/home_main_page.dart';
import 'package:infy/views/pages/caregivers/home/home_care_page.dart';
import 'package:infy/views/pages/caregivers/home/home_patient_page.dart';
import 'package:infy/views/pages/caregivers/settings/settings_page.dart';
import 'package:infy/views/pages/welcome_page.dart';
import 'package:infy/views/widgets/color_widget.dart';
import 'package:infy/views/widgets/navbar_widget.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedPageNotifier.value);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    selectedPageNotifier.value = index;
  }

  void _onNavbarTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si l'utilisateur est authentifié avec Firebase Auth
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Si l'utilisateur n'est pas connecté, rediriger vers la page d'accueil
      return const WelcomePage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          ImageString.logoFull,
          fit: BoxFit.contain,
          height: kToolbarHeight * 0.70,
        ),
        centerTitle: true,
        actions: [
          kDebugMode
              ? IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeColorViewer(),
                    ),
                  );
                },
              )
              : const SizedBox(),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [CarePage(), HomeMainPage(), PatientPage()],
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return NavbarWidget(
            currentIndex: selectedPage,
            onTap: _onNavbarTapped,
          );
        },
      ),
    );
  }
}

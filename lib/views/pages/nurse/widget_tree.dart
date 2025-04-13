import 'package:flutter/material.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/notifiers.dart';
import 'package:infy/views/pages/nurse/home/home_page.dart';
import 'package:infy/views/pages/nurse/home/care_page.dart';
import 'package:infy/views/pages/nurse/home/patient_page.dart';
import 'package:infy/views/pages/nurse/settings/settings_page.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          ImageString.logoFull,
          fit: BoxFit.contain,
          height: kToolbarHeight * 0.80,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SettingsPage();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [CarePage(), HomePage(), PatientPage()],
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

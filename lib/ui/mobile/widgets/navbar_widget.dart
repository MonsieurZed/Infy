import 'package:flutter/material.dart';
import 'package:infy/contants/strings.dart';

class NavbarWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavbarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services),
          label: AppStrings.navbarCare,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppStrings.navbarHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: AppStrings.navbarPatients,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infy/utils/general_notifiers.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/ui/mobile/pages/profile_page.dart';
import 'package:infy/ui/mobile/pages/welcome_page.dart';
import 'package:infy/services/theme_service.dart';
import 'package:infy/providers/user_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // Accéder au UserProvider pour vérifier l'état de l'authentification
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton de changement de thème avec ValueListenableBuilder
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeModeNotifier,
                builder: (context, currentThemeMode, _) {
                  return SwitchListTile.adaptive(
                    title: const Text(AppStrings.darkModeToggle),
                    subtitle: Text(
                      currentThemeMode == ThemeMode.dark
                          ? 'Mode sombre activé'
                          : 'Mode clair activé',
                    ),
                    value: currentThemeMode == ThemeMode.dark,
                    onChanged: (value) async {
                      await ThemeService.toggleThemeMode();
                      // Pas besoin de setState car ValueListenableBuilder se mettra à jour automatiquement

                      // Mise à jour de isDarkModeNotifier pour la compatibilité avec le reste de l'app
                      isDarkModeNotifier.value =
                          themeModeNotifier.value == ThemeMode.dark;
                    },
                    secondary: Icon(
                      currentThemeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  );
                },
              ),

              ListTile(
                title: const Text(AppStrings.profile),
                leading: const Icon(Icons.person),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text(AppStrings.logoutButton),
                leading: const Icon(Icons.logout),
                onTap: () async {
                  // Utiliser le UserProvider pour la déconnexion
                  try {
                    await userProvider.signOut();
                    if (mounted) {
                      selectedPageNotifier.value =
                          1; // Réinitialiser la page sélectionnée
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomePage(),
                        ),
                        (route) =>
                            false, // Supprimer toutes les routes précédentes
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${AppStrings.errorLogout}: $e'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

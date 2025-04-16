// Importation nécessaire pour accéder à ThemeMode et ThemeService
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:infy/data/services/theme_service.dart';

/// Widget qui affiche toutes les couleurs du thème actuel
class ThemeColorViewer extends StatefulWidget {
  const ThemeColorViewer({super.key});

  @override
  State<ThemeColorViewer> createState() => _ThemeColorViewerState();
}

class _ThemeColorViewerState extends State<ThemeColorViewer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Colors'),
        centerTitle: true,
        actions: [
          // Bouton pour changer le thème
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Passer au mode clair' : 'Passer au mode sombre',
            onPressed: () {
              _toggleTheme(context);
            },
          ),
        ],
      ),

      body: Center(
        // Ajout du Centre pour aligner le scroll au centre
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Couleurs du thème ${isDark ? "sombre" : "clair"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment:
                    WrapAlignment.center, // Centrer les éléments dans le Wrap

                children: [
                  _buildColorItem('primary', colorScheme.primary),
                  _buildColorItem('onPrimary', colorScheme.onPrimary),
                  _buildColorItem(
                    'primaryContainer',
                    colorScheme.primaryContainer,
                  ),
                  _buildColorItem(
                    'onPrimaryContainer',
                    colorScheme.onPrimaryContainer,
                  ),
                  _buildColorItem('secondary', colorScheme.secondary),
                  _buildColorItem('onSecondary', colorScheme.onSecondary),
                  _buildColorItem(
                    'secondaryContainer',
                    colorScheme.secondaryContainer,
                  ),
                  _buildColorItem(
                    'onSecondaryContainer',
                    colorScheme.onSecondaryContainer,
                  ),
                  _buildColorItem('tertiary', colorScheme.tertiary),
                  _buildColorItem('onTertiary', colorScheme.onTertiary),
                  _buildColorItem(
                    'tertiaryContainer',
                    colorScheme.tertiaryContainer,
                  ),
                  _buildColorItem(
                    'onTertiaryContainer',
                    colorScheme.onTertiaryContainer,
                  ),
                  _buildColorItem('error', colorScheme.error),
                  _buildColorItem('onError', colorScheme.onError),
                  _buildColorItem('errorContainer', colorScheme.errorContainer),
                  _buildColorItem(
                    'onErrorContainer',
                    colorScheme.onErrorContainer,
                  ),
                  _buildColorItem('surface', colorScheme.surface),
                  _buildColorItem('onSurface', colorScheme.onSurface),
                  _buildColorItem(
                    'surfaceContainerLowest',
                    colorScheme.surfaceContainerLowest,
                  ),
                  _buildColorItem(
                    'surfaceContainerLow',
                    colorScheme.surfaceContainerLow,
                  ),
                  _buildColorItem(
                    'surfaceContainer',
                    colorScheme.surfaceContainer,
                  ),
                  _buildColorItem(
                    'surfaceContainerHigh',
                    colorScheme.surfaceContainerHigh,
                  ),
                  _buildColorItem(
                    'surfaceContainerHighest',
                    colorScheme.surfaceContainerHighest,
                  ),
                  _buildColorItem(
                    'onSurfaceVariant',
                    colorScheme.onSurfaceVariant,
                  ),
                  _buildColorItem('outline', colorScheme.outline),
                  _buildColorItem('outlineVariant', colorScheme.outlineVariant),
                  _buildColorItem('shadow', colorScheme.shadow),
                  _buildColorItem('scrim', colorScheme.scrim),
                  _buildColorItem('inverseSurface', colorScheme.inverseSurface),
                  _buildColorItem(
                    'onInverseSurface',
                    colorScheme.onInverseSurface,
                  ),
                  _buildColorItem('inversePrimary', colorScheme.inversePrimary),
                  _buildColorItem('surfaceTint', colorScheme.surfaceTint),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorItem(String name, Color color) {
    // Déterminer si nous devons utiliser du texte blanc ou noir basé sur la luminosité de la couleur
    final bool useWhiteText =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: useWhiteText ? Colors.white : Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: TextStyle(
                    color: useWhiteText ? Colors.white70 : Colors.black54,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggleTheme(BuildContext context) async {
    // Basculer entre les thèmes et mettre à jour l'interface
    await ThemeService.toggleThemeMode();
    setState(() {}); // Forcer la mise à jour de l'interface
  }
}

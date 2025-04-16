import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Nombre de niveaux de pile affichés
      errorMethodCount: 8, // Nombre de niveaux pour les erreurs
      lineLength: 120, // Longueur maximale des lignes
      colors: true, // Activer les couleurs
      printEmojis: true, // Activer les emojis
    ),
  );

  static get log => logger.log;
  static get d => logger.d;
  static get i => logger.i;
  static get w => logger.w;
  static get e => logger.e;

  static void snackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior
                .floating, // Permet de détacher la snackbar des bords
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Définit les marges
      ),
    );
  }

  static void debug(StackTrace stackTrace, String message) {
    if (kDebugMode) {
      debugPrint('${stackTrace.toString().split("\n")[1]}: $message');
    }
    logger.e('Debugging', stackTrace: stackTrace);
  }
}

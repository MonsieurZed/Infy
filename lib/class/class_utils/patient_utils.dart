import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class PatientUtils {
  static const String chars = 'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789';
  static final Random random = Random();

  // Méthode pour générer un ID unique au format <year:2><dayoftheyear:HEXADECIMAL><rand:4>
  static String _generateUniqueId() {
    final now = DateTime.now();
    final year = now.year % 100; // Les deux derniers chiffres de l'année
    final dayOfYear = int.parse(DateFormat("D").format(now)); // Jour de l'année
    final dayHex = dayOfYear
        .toRadixString(16)
        .toUpperCase()
        .padLeft(3, '0'); // Convertir en hexadécimal et remplir à gauche

    // Générer 4 caractères aléatoires
    final randomPart = String.fromCharCodes(
      Iterable.generate(
        5,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

    return '$year$dayHex$randomPart';
  }

  // Méthode pour vérifier et générer un ID unique sur Firebase
  static Future<String> generateVerifiedUniqueId() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String id;

    do {
      id = _generateUniqueId();
      final doc = await firestore.collection('patients').doc(id).get();
      if (!doc.exists) {
        break; // L'ID est unique, on peut l'utiliser
      }
    } while (true);

    return id;
  }
}

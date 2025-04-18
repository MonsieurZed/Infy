import 'package:infy/contants/constants.dart';

class CareItem {
  final String documentId; // Document ID Firestore
  final String name; // Description du soin
  final String careType; // Type of care

  CareItem({
    required this.documentId,
    required this.name,
    required this.careType,
  });

  // Factory pour créer un CareItem à partir d'un document Firestore
  factory CareItem.fromJson(Map<String, dynamic> json) {
    return CareItem(
      documentId: json[FirebaseString.documentId] as String,
      name: json[FirebaseString.careItemName] as String,
      careType: json[FirebaseString.careItemType] as String,
    );
  }

  // Méthode pour convertir un CareItem en Map (pour Firestore)
  Map<String, dynamic> toJson() {
    return {
      FirebaseString.careItemName: name,
      FirebaseString.careItemType: careType,
    };
  }
}

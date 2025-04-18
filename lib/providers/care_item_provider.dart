import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infy/class/care_item_class.dart';
import 'package:infy/contants/constants.dart';
import 'package:infy/contants/strings.dart';

class CareItemProvider with ChangeNotifier {
  final List<CareItem> _careItems = []; // Liste locale des soins
  bool _isLoading = false;
  bool _loaded = false;

  List<CareItem> get careItems => _careItems;
  bool get isLoading => _isLoading;

  /// Récupérer tous les soins depuis Firebase
  Future<void> fetchCareItems({bool reload = false}) async {
    if (_loaded && !reload) return;
    _isLoading = true;

    if (reload) {
      _careItems.clear(); // Vider la liste existante si on recharge
    }

    notifyListeners(); // Notifier du chargement

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection(FirebaseString.collectionCareItems)
              .get();
      _careItems.addAll(
        snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return CareItem.fromJson({
            FirebaseString.documentId: doc.id,
            ...data,
          });
        }).toList(),
      );
    } catch (e) {
      debugPrint('${AppStrings.errorFetchingItem} CareItems : $e');
    } finally {
      _loaded = true;
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infy/data/class/care_item_class.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/strings.dart';

class CareItemProvider with ChangeNotifier {
  final List<CareItem> _careItems = []; // Liste locale des soins
  bool _isLoading = false;
  bool _loaded = false;

  List<CareItem> get careItems => _careItems;
  bool get isLoading => _isLoading;

  /// Récupérer tous les soins depuis Firebase
  Future<void> fetchCareItems() async {
    if (_loaded) return;
    _isLoading = true;
    notifyListeners();

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

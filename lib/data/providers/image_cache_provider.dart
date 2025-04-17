import 'package:flutter/material.dart';

/// Provider qui garde en mémoire les images déjà visualisées
/// pour éviter de les recharger à chaque fois
class ImageCacheProvider extends ChangeNotifier {
  // Cache des images (URL -> Image préconstruite)
  final Map<String, ImageProvider> _imageCache = {};

  // Limite maximale du cache (pour éviter une utilisation excessive de mémoire)
  final int _maxCacheSize = 50;

  // Queue des URLs pour gérer l'algorithme LRU (Least Recently Used)
  final List<String> _recentlyUsed = [];

  /// Récupère une image du cache ou la charge et l'ajoute au cache
  ImageProvider getImage(String url) {
    // Si l'image est déjà en cache, la mettre en tête de la liste des récemment utilisées
    if (_imageCache.containsKey(url)) {
      _recentlyUsed.remove(url);
      _recentlyUsed.add(url);
      return _imageCache[url]!;
    }

    // Si le cache est plein, supprimer l'image la moins récemment utilisée
    if (_imageCache.length >= _maxCacheSize) {
      final oldestUrl = _recentlyUsed.removeAt(0);
      _imageCache.remove(oldestUrl);
    }

    // Créer un nouveau NetworkImage et l'ajouter au cache
    final imageProvider = NetworkImage(url);
    _imageCache[url] = imageProvider;
    _recentlyUsed.add(url);

    // Ne pas précharger ici car nous n'avons pas de contexte valide
    // Cette étape sera gérée par la méthode preloadImage

    return imageProvider;
  }

  /// Précharge une image et l'ajoute au cache
  void preloadImage(String url, BuildContext context) {
    if (!_imageCache.containsKey(url)) {
      final imageProvider = NetworkImage(url);
      _imageCache[url] = imageProvider;
      _recentlyUsed.add(url);

      // Gérer la taille du cache
      if (_recentlyUsed.length > _maxCacheSize) {
        final oldestUrl = _recentlyUsed.removeAt(0);
        _imageCache.remove(oldestUrl);
      }

      // Précharger l'image avec le contexte fourni
      precacheImage(imageProvider, context);
    } else {
      // Si l'image est déjà en cache, mettre à jour son ordre dans la liste LRU
      _recentlyUsed.remove(url);
      _recentlyUsed.add(url);

      // Précharger quand même pour s'assurer que l'image est dans le cache Flutter
      precacheImage(_imageCache[url]!, context);
    }
  }

  /// Précharge une liste d'images
  void preloadImages(List<String> urls, BuildContext context) {
    for (final url in urls) {
      preloadImage(url, context);
    }
  }

  /// Efface le cache
  void clearCache() {
    _imageCache.clear();
    _recentlyUsed.clear();
    notifyListeners();
  }

  /// Vérifie si une image est dans le cache
  bool isImageCached(String url) {
    return _imageCache.containsKey(url);
  }

  /// Obtient la taille actuelle du cache
  int get cacheSize => _imageCache.length;
}

import 'package:flutter/material.dart';
import 'package:infy/data/contants/strings.dart';
import 'package:infy/data/providers/image_cache_provider.dart';
import 'package:provider/provider.dart';

class ImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;
  final Set<int> _preloadedImages = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Préchargement des images au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadVisibleImages();
    });
  }

  // Précharge l'image actuelle et les images adjacentes
  void _preloadVisibleImages() {
    final imageCacheProvider = Provider.of<ImageCacheProvider>(
      context,
      listen: false,
    );

    // Précharger l'image actuelle
    if (_currentIndex >= 0 && _currentIndex < widget.imageUrls.length) {
      imageCacheProvider.preloadImage(widget.imageUrls[_currentIndex], context);
      _preloadedImages.add(_currentIndex);
    }

    // Précharger l'image suivante
    if (_currentIndex + 1 < widget.imageUrls.length) {
      imageCacheProvider.preloadImage(
        widget.imageUrls[_currentIndex + 1],
        context,
      );
      _preloadedImages.add(_currentIndex + 1);
    }

    // Précharger l'image précédente
    if (_currentIndex - 1 >= 0) {
      imageCacheProvider.preloadImage(
        widget.imageUrls[_currentIndex - 1],
        context,
      );
      _preloadedImages.add(_currentIndex - 1);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Accéder au provider de cache d'images
    final imageCacheProvider = Provider.of<ImageCacheProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          _showControls
              ? AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                title: Text(
                  '${AppStrings.imageViewerTitle} ${_currentIndex + 1}/${widget.imageUrls.length}',
                ),
                iconTheme: const IconThemeData(color: Colors.white),
              )
              : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                // Précharger l'image suivante et précédente lors du changement de page
                _preloadVisibleImages();
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: Image(
                      // Utiliser le provider pour obtenir l'image
                      image: imageCacheProvider.getImage(
                        widget.imageUrls[index],
                      ),
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

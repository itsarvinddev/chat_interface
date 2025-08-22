// Optimized image loading service for ChatUI
// Provides smart caching, lazy loading, and memory optimization for images

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'performance_service.dart';

/// Optimized image loading service with smart caching and lazy loading
class OptimizedImageService {
  static const int _maxConcurrentLoads = 3;
  static const Duration _loadTimeout = Duration(seconds: 30);
  static const int _maxImageDimension = 1024;

  final PerformanceService _performanceService = PerformanceService();
  final Map<String, Completer<ImageInfo?>> _loadingImages = {};
  final Map<String, ImageInfo> _imageInfoCache = {};
  final Set<String> _failedImages = {};

  int _currentLoadingCount = 0;
  final Queue<_ImageLoadRequest> _loadQueue = Queue<_ImageLoadRequest>();

  static final OptimizedImageService _instance =
      OptimizedImageService._internal();
  factory OptimizedImageService() => _instance;
  OptimizedImageService._internal();

  /// Load image with optimization and caching
  Future<ImageInfo?> loadOptimizedImage(
    String url, {
    int? maxWidth,
    int? maxHeight,
    bool enableCaching = true,
    ImageErrorWidgetBuilder? errorBuilder,
  }) async {
    try {
      // Check if image loading failed before
      if (_failedImages.contains(url)) {
        return null;
      }

      // Check cache first
      if (enableCaching) {
        final cached = _imageInfoCache[url];
        if (cached != null) {
          return cached;
        }

        // Check performance service cache
        final cachedData = _performanceService.getCachedImage(url);
        if (cachedData != null) {
          final imageInfo = await _decodeImageFromData(cachedData);
          if (imageInfo != null) {
            _imageInfoCache[url] = imageInfo;
            return imageInfo;
          }
        }
      }

      // Check if already loading
      final existingCompleter = _loadingImages[url];
      if (existingCompleter != null) {
        return await existingCompleter.future;
      }

      // Create new loading request
      final completer = Completer<ImageInfo?>();
      _loadingImages[url] = completer;

      // Add to queue or start loading immediately
      final request = _ImageLoadRequest(
        url: url,
        maxWidth: maxWidth ?? _maxImageDimension,
        maxHeight: maxHeight ?? _maxImageDimension,
        enableCaching: enableCaching,
        completer: completer,
      );

      if (_currentLoadingCount < _maxConcurrentLoads) {
        _startLoading(request);
      } else {
        _loadQueue.add(request);
      }

      return await completer.future.timeout(_loadTimeout);
    } catch (e) {
      debugPrint('Error loading optimized image: $e');
      _failedImages.add(url);
      _loadingImages.remove(url);
      return null;
    }
  }

  /// Preload images for better performance
  Future<void> preloadImages(List<String> urls) async {
    try {
      final futures = urls.map((url) => loadOptimizedImage(url));
      await Future.wait(futures, eagerError: false);
    } catch (e) {
      debugPrint('Error preloading images: $e');
    }
  }

  /// Clear image caches
  void clearImageCache() {
    try {
      _imageInfoCache.clear();
      _failedImages.clear();

      // Cancel ongoing loads
      for (final completer in _loadingImages.values) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      }
      _loadingImages.clear();
      _loadQueue.clear();
      _currentLoadingCount = 0;
    } catch (e) {
      debugPrint('Error clearing image cache: $e');
    }
  }

  /// Start loading an image request
  void _startLoading(_ImageLoadRequest request) async {
    _currentLoadingCount++;

    try {
      final imageInfo = await _loadAndOptimizeImage(request);

      if (imageInfo != null && request.enableCaching) {
        _imageInfoCache[request.url] = imageInfo;
      }

      if (!request.completer.isCompleted) {
        request.completer.complete(imageInfo);
      }
    } catch (e) {
      debugPrint('Error in image loading: $e');
      _failedImages.add(request.url);

      if (!request.completer.isCompleted) {
        request.completer.complete(null);
      }
    } finally {
      _loadingImages.remove(request.url);
      _currentLoadingCount--;

      // Process next item in queue
      if (_loadQueue.isNotEmpty && _currentLoadingCount < _maxConcurrentLoads) {
        final nextRequest = _loadQueue.removeFirst();
        _startLoading(nextRequest);
      }
    }
  }

  /// Load and optimize image
  Future<ImageInfo?> _loadAndOptimizeImage(_ImageLoadRequest request) async {
    try {
      Uint8List? imageData;

      // Load image data
      if (request.url.startsWith('http')) {
        imageData = await _loadFromNetwork(request.url);
      } else if (request.url.startsWith('file://')) {
        imageData = await _loadFromFile(request.url);
      } else if (request.url.startsWith('asset://')) {
        imageData = await _loadFromAsset(request.url.substring(8));
      } else {
        // Try as asset path
        imageData = await _loadFromAsset(request.url);
      }

      if (imageData == null) return null;

      // Optimize image size
      final optimizedData = await _optimizeImageSize(
        imageData,
        request.maxWidth,
        request.maxHeight,
      );

      // Cache optimized data
      if (request.enableCaching && optimizedData != null) {
        _performanceService.cacheImage(request.url, optimizedData);
      }

      // Decode to ImageInfo
      return await _decodeImageFromData(optimizedData ?? imageData);
    } catch (e) {
      debugPrint('Error loading and optimizing image: $e');
      return null;
    }
  }

  /// Load image from network
  Future<Uint8List?> _loadFromNetwork(String url) async {
    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 10);

      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        return bytes;
      }

      return null;
    } catch (e) {
      debugPrint('Error loading image from network: $e');
      return null;
    }
  }

  /// Load image from file
  Future<Uint8List?> _loadFromFile(String filePath) async {
    try {
      final file = File(filePath.substring(7)); // Remove 'file://' prefix
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error loading image from file: $e');
      return null;
    }
  }

  /// Load image from asset
  Future<Uint8List?> _loadFromAsset(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading image from asset: $e');
      return null;
    }
  }

  /// Optimize image size to reduce memory usage
  Future<Uint8List?> _optimizeImageSize(
    Uint8List imageData,
    int maxWidth,
    int maxHeight,
  ) async {
    try {
      final codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: maxWidth,
        targetHeight: maxHeight,
      );

      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Convert back to bytes if resized
      if (image.width != maxWidth || image.height != maxHeight) {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          return byteData.buffer.asUint8List();
        }
      }

      return imageData;
    } catch (e) {
      debugPrint('Error optimizing image size: $e');
      return imageData;
    }
  }

  /// Decode image data to ImageInfo
  Future<ImageInfo?> _decodeImageFromData(Uint8List data) async {
    try {
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();

      return ImageInfo(image: frame.image, scale: 1.0);
    } catch (e) {
      debugPrint('Error decoding image: $e');
      return null;
    }
  }

  /// Get loading statistics
  Map<String, dynamic> getLoadingStats() {
    return {
      'currentlyLoading': _currentLoadingCount,
      'queuedLoads': _loadQueue.length,
      'cachedImages': _imageInfoCache.length,
      'failedImages': _failedImages.length,
    };
  }
}

/// Image load request data class
class _ImageLoadRequest {
  final String url;
  final int maxWidth;
  final int maxHeight;
  final bool enableCaching;
  final Completer<ImageInfo?> completer;

  _ImageLoadRequest({
    required this.url,
    required this.maxWidth,
    required this.maxHeight,
    required this.enableCaching,
    required this.completer,
  });
}

/// Optimized image widget with lazy loading and caching
class OptimizedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableCaching;
  final bool enableLazyLoading;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableCaching = true,
    this.enableLazyLoading = true,
  });

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  final OptimizedImageService _imageService = OptimizedImageService();
  ImageInfo? _imageInfo;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    if (!widget.enableLazyLoading) {
      _loadImage();
    }
  }

  @override
  void didUpdateWidget(OptimizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      _imageInfo = null;
      _hasError = false;
      if (_isVisible || !widget.enableLazyLoading) {
        _loadImage();
      }
    }
  }

  void _onVisibilityChanged(bool isVisible) {
    if (isVisible && !_isVisible && widget.enableLazyLoading) {
      _isVisible = true;
      if (_imageInfo == null && !_isLoading && !_hasError) {
        _loadImage();
      }
    }
  }

  Future<void> _loadImage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final imageInfo = await _imageService.loadOptimizedImage(
        widget.imageUrl,
        maxWidth: widget.width?.toInt() ?? 512,
        maxHeight: widget.height?.toInt() ?? 512,
        enableCaching: widget.enableCaching,
      );

      if (mounted) {
        setState(() {
          _imageInfo = imageInfo;
          _isLoading = false;
          _hasError = imageInfo == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enableLazyLoading) {
      return VisibilityDetector(
        key: ValueKey(widget.imageUrl),
        onVisibilityChanged: (info) {
          _onVisibilityChanged(info.visibleFraction > 0);
        },
        child: _buildImage(),
      );
    }

    return _buildImage();
  }

  Widget _buildImage() {
    if (_hasError) {
      return widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: const Icon(Icons.error, color: Colors.grey),
          );
    }

    if (_isLoading || _imageInfo == null) {
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
    }

    return RawImage(
      image: _imageInfo!.image,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      scale: _imageInfo!.scale,
    );
  }
}

/// Simple visibility detector for lazy loading
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final ValueChanged<VisibilityInfo> onVisibilityChanged;
  @override
  final Key key;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  Widget build(BuildContext context) {
    // Simplified visibility detection
    // In production, you might want to use a more sophisticated solution
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onVisibilityChanged(VisibilityInfo(visibleFraction: 1.0));
    });

    return widget.child;
  }
}

/// Visibility information data class
class VisibilityInfo {
  final double visibleFraction;

  VisibilityInfo({required this.visibleFraction});
}

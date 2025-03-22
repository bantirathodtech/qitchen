// File: screens/home/widgets/promotion_banner.dart

import 'package:flutter/material.dart';

import '../../../../../common/log/loggers.dart';

class PromotionBanner extends StatelessWidget {
  static const String TAG = '[PromotionBanner]';

  final String bannerUrl;
  final VoidCallback onTap;

  // Default banner URL and dimensions
  static const String DEFAULT_BANNER = 'assets/images/default_promotion.png';
  static const double BANNER_HEIGHT = 200.0;

  const PromotionBanner({
    super.key,
    required this.bannerUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.logDebug('$TAG: Building banner with URL: $bannerUrl');

    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: BANNER_HEIGHT,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildBannerImage(),
              ),
              _buildGradientOverlay(),
              _buildShadowOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildShadowOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildBannerImage() {
    try {
      // First try to use provided URL
      final cleanUrl = _cleanUrl(bannerUrl);
      if (cleanUrl.isEmpty) {
        AppLogger.logWarning(
            '$TAG: Invalid or empty URL, using default banner');
        return _buildDefaultBanner();
      }

      // Attempt to load network image
      return Image.network(
        cleanUrl,
        width: double.infinity,
        height: BANNER_HEIGHT,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          AppLogger.logError('$TAG: Error loading banner image: $error');
          return _buildDefaultBanner(); // Use default banner on error
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingIndicator(loadingProgress);
        },
      );
    } catch (e) {
      AppLogger.logError('$TAG: Error creating banner image: $e');
      return _buildDefaultBanner();
    }
  }

  Widget _buildDefaultBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        DEFAULT_BANNER,
        width: double.infinity,
        height: BANNER_HEIGHT,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          AppLogger.logError('$TAG: Error loading default banner: $error');
          return _buildFallbackImage(); // Only use fallback if asset fails
        },
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade500,
          ],
        ),
      ),
      child: _buildPlaceholderContent(),
    );
  }

  Widget _buildPlaceholderContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.local_offer,
            size: 48,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Special Offers',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent? loadingProgress) {
    return Container(
      width: double.infinity,
      height: BANNER_HEIGHT,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            value: loadingProgress?.expectedTotalBytes != null
                ? loadingProgress!.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade500),
          ),
        ),
      ),
    );
  }

  String _cleanUrl(String url) {
    try {
      if (url.isEmpty) {
        AppLogger.logWarning('$TAG: Empty URL provided');
        return '';
      }

      // Remove any HTML tags and decode entities
      final cleanedUrl = url
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&amp;', '&')
          .trim();

      // Validate URL
      final uri = Uri.parse(cleanedUrl);
      if (!uri.isScheme('http') && !uri.isScheme('https')) {
        AppLogger.logWarning('$TAG: Invalid URL scheme: ${uri.scheme}');
        return '';
      }

      AppLogger.logDebug('$TAG: Cleaned URL: $cleanedUrl');
      return cleanedUrl;
    } catch (e) {
      AppLogger.logWarning('$TAG: Error cleaning URL: $e');
      return '';
    }
  }
}

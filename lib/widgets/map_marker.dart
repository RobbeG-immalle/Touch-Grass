import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:touch_grass/config/theme.dart';
import 'package:touch_grass/models/post_model.dart';

/// A custom map marker widget. In google_maps_flutter, markers use BitmapDescriptor
/// rather than Flutter widgets. This class provides a helper to build marker data
/// and a small preview card for tapped markers shown as overlays.
class MapMarkerCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onClose;

  const MapMarkerCard({super.key, required this.post, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 48),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.caption.isNotEmpty)
                    Text(
                      post.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if (post.locationName.isNotEmpty)
                    Text(
                      post.locationName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 14,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a standard green [BitmapDescriptor] for use as a map marker icon.
  static BitmapDescriptor get defaultMarkerIcon =>
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
}

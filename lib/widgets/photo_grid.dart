import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:touch_grass/models/post_model.dart';

/// A masonry-style 3-column grid of post images.
class PhotoGrid extends StatelessWidget {
  final List<PostModel> posts;

  const PhotoGrid({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📷', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                'No posts yet',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, i) => _GridItem(post: posts[i]),
    );
  }
}

class _GridItem extends StatelessWidget {
  final PostModel post;
  const _GridItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: post.imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.grey.shade200),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}

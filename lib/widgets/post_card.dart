import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:touch_grass/config/theme.dart';
import 'package:touch_grass/models/post_model.dart';
import 'package:touch_grass/widgets/comments_sheet.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final String currentUid;
  final VoidCallback onLike;
  final int? rank;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUid,
    required this.onLike,
    this.rank,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _currentImageIndex = 0;

  void _openComments() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CommentsSheet(postId: widget.post.postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liked = widget.post.likedBy.contains(widget.currentUid);
    final theme = Theme.of(context);
    final images = widget.post.imageUrls;
    final multiImage = images.length > 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                if (widget.rank != null) ...[
                  _RankBadge(rank: widget.rank!),
                  const SizedBox(width: 8),
                ],
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    widget.post.username.isNotEmpty
                        ? widget.post.username[0].toUpperCase()
                        : (widget.post.userId.isNotEmpty
                            ? widget.post.userId[0].toUpperCase()
                            : '?'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username.isNotEmpty
                            ? widget.post.username
                            : widget.post.userId,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.post.locationName.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                widget.post.locationName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Text(
                  timeago.format(widget.post.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Image(s)
          if (images.isEmpty)
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 48),
              ),
            )
          else if (multiImage)
            _MultiImageView(
              urls: images,
              currentIndex: _currentImageIndex,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
            )
          else
            AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: images.first,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : null,
                  ),
                  onPressed: widget.onLike,
                ),
                Text(
                  '${widget.post.likes}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: _openComments,
                ),
                Text(
                  '${widget.post.commentCount}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _VisibilityBadge(visibility: widget.post.visibility),
              ],
            ),
          ),

          // Caption
          if (widget.post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                widget.post.caption,
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// A PageView of images with dot indicators.
class _MultiImageView extends StatelessWidget {
  final List<String> urls;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _MultiImageView({
    required this.urls,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            itemCount: urls.length,
            onPageChanged: onPageChanged,
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: urls[i],
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 48),
              ),
            ),
          ),
        ),
        // Dot indicators
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              urls.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == currentIndex ? 8 : 6,
                height: i == currentIndex ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == currentIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final String emoji;
    if (rank == 1) {
      emoji = '🥇';
    } else if (rank == 2) {
      emoji = '🥈';
    } else if (rank == 3) {
      emoji = '🥉';
    } else {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return Text(emoji, style: const TextStyle(fontSize: 22));
  }
}

class _VisibilityBadge extends StatelessWidget {
  final String visibility;
  const _VisibilityBadge({required this.visibility});

  @override
  Widget build(BuildContext context) {
    final isPublic = visibility == 'public';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPublic ? Icons.public : Icons.group,
          size: 14,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          isPublic ? 'Public' : 'Friends',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}


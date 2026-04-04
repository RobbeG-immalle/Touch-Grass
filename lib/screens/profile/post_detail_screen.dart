import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/models/post_model.dart';
import 'package:touch_grass/providers/auth_provider.dart';
import 'package:touch_grass/providers/posts_provider.dart';
import 'package:touch_grass/widgets/post_card.dart';

/// Displays a single post with full interaction (like, comment, delete).
class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final posts = context.watch<PostsProvider>();
    final currentUid = auth.currentUser?.uid ?? '';
    final isOwner = post.userId == currentUid;

    // Find the latest version of the post from the provider (for live updates).
    final livePost = posts.userPosts.where((p) => p.postId == post.postId).firstOrNull
        ?? posts.feed.where((p) => p.postId == post.postId).firstOrNull
        ?? post;

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: SingleChildScrollView(
        child: PostCard(
          post: livePost,
          currentUid: currentUid,
          onLike: () => posts.toggleLike(livePost.postId),
          onDelete: isOwner
              ? () async {
                  await posts.deletePost(
                    livePost.postId,
                    livePost.imageUrls,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              : null,
        ),
      ),
    );
  }
}

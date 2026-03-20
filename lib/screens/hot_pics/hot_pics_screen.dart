import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/providers/auth_provider.dart';
import 'package:touch_grass/providers/posts_provider.dart';
import 'package:touch_grass/widgets/post_card.dart';

class HotPicsScreen extends StatefulWidget {
  const HotPicsScreen({super.key});

  @override
  State<HotPicsScreen> createState() => _HotPicsScreenState();
}

class _HotPicsScreenState extends State<HotPicsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PostsProvider>().subscribeToPublicPosts();
  }

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostsProvider>().publicPosts;
    final sorted = [...posts]..sort((a, b) => b.likes.compareTo(a.likes));
    final currentUid = context.watch<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Hot Pics'),
        centerTitle: true,
      ),
      body: sorted.isEmpty
          ? const _EmptyHotPics()
          : ListView.builder(
              itemCount: sorted.length,
              itemBuilder: (context, i) {
                final post = sorted[i];
                return PostCard(
                  post: post,
                  currentUid: currentUid,
                  onLike: () =>
                      context.read<PostsProvider>().toggleLike(post.postId),
                  rank: i + 1,
                );
              },
            ),
    );
  }
}

class _EmptyHotPics extends StatelessWidget {
  const _EmptyHotPics();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌵', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No hot pics yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Post publicly to appear here!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

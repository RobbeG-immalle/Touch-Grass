import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/providers/auth_provider.dart';
import 'package:touch_grass/providers/posts_provider.dart';
import 'package:touch_grass/widgets/bottom_nav_bar.dart';
import 'package:touch_grass/widgets/post_card.dart';
import 'package:touch_grass/widgets/streak_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        break; // already on home
      case 1:
        context.push('/explore');
        break;
      case 2:
        context.push('/hot-pics');
        break;
      case 3:
        context.push('/friends');
        break;
      case 4:
        context.push('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final posts = context.watch<PostsProvider>();
    final user = auth.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Touch Grass'),
            actions: [
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: StreakBadge(streak: user.currentStreak, compact: true),
                ),
            ],
          ),
          if (posts.error != null)
            SliverFillRemaining(
              child: _FeedError(message: posts.error!),
            )
          else if (posts.feed.isEmpty)
            SliverFillRemaining(
              child: _EmptyFeed(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final post = posts.feed[i];
                  return PostCard(
                    post: post,
                    currentUid: user?.uid ?? '',
                    onLike: () => posts.toggleLike(post.postId),
                  );
                },
                childCount: posts.feed.length,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/camera'),
        child: const Icon(Icons.camera_alt_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }
}

class _FeedError extends StatelessWidget {
  final String message;
  const _FeedError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Could not load feed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Nothing here yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add friends or post your first photo!',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/camera'),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Post Now'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(160, 48),
            ),
          ),
        ],
      ),
    );
  }
}

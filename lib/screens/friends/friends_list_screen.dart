import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/config/constants.dart';
import 'package:touch_grass/models/friendship_model.dart';
import 'package:touch_grass/models/user_model.dart';
import 'package:touch_grass/providers/auth_provider.dart';
import 'package:touch_grass/providers/friends_provider.dart';

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friends = context.watch<FriendsProvider>();
    final currentUid = context.watch<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => context.push('/friends/add'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: CustomScrollView(
          slivers: [
            // Pending requests
            if (friends.pendingReceived.isNotEmpty) ...[
              _SliverHeader(
                'Requests (${friends.pendingReceived.length})',
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final req = friends.pendingReceived[i];
                    return _PendingRequestTile(
                      friendship: req,
                      currentUid: currentUid,
                      onAccept: () => friends.acceptRequest(req.id),
                    );
                  },
                  childCount: friends.pendingReceived.length,
                ),
              ),
            ],

            // Friends list
            _SliverHeader('Friends (${friends.friends.length})'),
            friends.friends.isEmpty
                ? SliverFillRemaining(child: _EmptyFriends())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final friend = friends.friends[i];
                        final fid = friends.friendshipIdWith(friend.uid);
                        return _FriendTile(
                          user: friend,
                          onRemove: fid != null
                              ? () => friends.removeFriend(friend.uid, fid)
                              : null,
                        );
                      },
                      childCount: friends.friends.length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _SliverHeader extends StatelessWidget {
  final String title;
  const _SliverHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onRemove;

  const _FriendTile({required this.user, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl.isNotEmpty
            ? CachedNetworkImageProvider(user.avatarUrl)
            : null,
        child: user.avatarUrl.isEmpty
            ? Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?')
            : null,
      ),
      title: Text('@${user.username}'),
      subtitle: Text('🔥 ${user.currentStreak} day streak'),
      trailing: onRemove != null
          ? PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'remove') onRemove!();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove friend'),
                ),
              ],
            )
          : null,
    );
  }
}

class _PendingRequestTile extends StatelessWidget {
  final FriendshipModel friendship;
  final String currentUid;
  final VoidCallback onAccept;

  const _PendingRequestTile({
    required this.friendship,
    required this.currentUid,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final friends = context.watch<FriendsProvider>();
    final user = friends.pendingUsers[friendship.requestedBy];
    final displayName = user != null && user.username.isNotEmpty
        ? '@${user.username}'
        : friendship.requestedBy;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user != null && user.avatarUrl.isNotEmpty
            ? CachedNetworkImageProvider(user.avatarUrl)
            : null,
        child: user == null || user.avatarUrl.isEmpty
            ? const Icon(Icons.person_outline)
            : null,
      ),
      title: Text('Friend request from $displayName'),
      subtitle: const Text('Wants to be your friend'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: onAccept,
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👥', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No friends yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => context.push('/friends/add'),
            icon: const Icon(Icons.person_add),
            label: const Text('Find Friends'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(160, 44),
            ),
          ),
        ],
      ),
    );
  }
}

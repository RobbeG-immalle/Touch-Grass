import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/models/user_model.dart';
import 'package:touch_grass/providers/auth_provider.dart';
import 'package:touch_grass/providers/friends_provider.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _ctrl = TextEditingController();
  UserModel? _result;
  bool _searching = false;
  String? _searchError;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final username = _ctrl.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _searching = true;
      _result = null;
      _searchError = null;
    });

    final friends = context.read<FriendsProvider>();
    final user = await friends.searchByUsername(username);

    final currentUid = context.read<AuthProvider>().currentUser?.uid;

    if (mounted) {
      setState(() {
        _searching = false;
        if (user == null) {
          _searchError = 'No user found with username "$username"';
        } else if (user.uid == currentUid) {
          _searchError = "That's you! 🌿";
        } else {
          _result = user;
        }
      });
    }
  }

  Future<void> _sendRequest(String toUid) async {
    final friends = context.read<FriendsProvider>();
    await friends.sendRequest(toUid);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent! 🌿')),
      );
      setState(() => _result = null);
      _ctrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final friends = context.watch<FriendsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Friend')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Search by username…',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searching ? null : _search,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 52),
                  ),
                  child: _searching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_searchError != null) ...[
              Text(
                _searchError!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
            if (_result != null) ...[
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: _result!.avatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(_result!.avatarUrl)
                        : null,
                    child: _result!.avatarUrl.isEmpty
                        ? Text(
                            _result!.username.isNotEmpty
                                ? _result!.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 20),
                          )
                        : null,
                  ),
                  title: Text(
                    '@${_result!.username}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('🔥 ${_result!.currentStreak} day streak'),
                  trailing: friends.isFriend(_result!.uid)
                      ? Chip(
                          label: const Text('Friends'),
                          avatar: const Icon(Icons.check, size: 16),
                        )
                      : friends.hasPendingRequest(_result!.uid)
                          ? const Chip(label: Text('Requested'))
                          : ElevatedButton(
                              onPressed: friends.isLoading
                                  ? null
                                  : () => _sendRequest(_result!.uid),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(100, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              child: const Text('Add'),
                            ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

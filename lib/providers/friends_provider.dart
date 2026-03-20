import 'package:flutter/foundation.dart';
import 'package:touch_grass/config/constants.dart';
import 'package:touch_grass/models/friendship_model.dart';
import 'package:touch_grass/models/user_model.dart';
import 'package:touch_grass/services/database_service.dart';

class FriendsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  UserModel? _currentUser;
  List<FriendshipModel> _friendships = [];
  List<UserModel> _friends = [];
  bool _isLoading = false;
  String? _error;

  List<FriendshipModel> get friendships => _friendships;
  List<UserModel> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<FriendshipModel> get pendingReceived {
    final uid = _currentUser?.uid;
    if (uid == null) return [];
    return _friendships
        .where(
          (f) =>
              f.isPending &&
              f.user2 == uid, // received by current user
        )
        .toList();
  }

  List<FriendshipModel> get pendingSent {
    final uid = _currentUser?.uid;
    if (uid == null) return [];
    return _friendships
        .where((f) => f.isPending && f.requestedBy == uid)
        .toList();
  }

  void updateUser(UserModel? user) {
    _currentUser = user;
    if (user != null) _subscribe();
  }

  void _subscribe() {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    _db.friendshipsStream(uid).listen((list) async {
      _friendships = list;
      final accepted = list.where((f) => f.isAccepted).toList();
      final friendUids = accepted.map((f) {
        final uid2 = _currentUser!.uid;
        return f.user1 == uid2 ? f.user2 : f.user1;
      }).toList();
      final users = await Future.wait(
        friendUids.map((id) => _db.getUser(id)),
      );
      _friends = users.whereType<UserModel>().toList();
      notifyListeners();
    });
  }

  Future<void> sendRequest(String toUid) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _db.sendFriendRequest(fromUid: uid, toUid: toUid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String friendshipId) async {
    await _db.acceptFriendRequest(friendshipId);
  }

  Future<void> removeFriend(String friendUid, String friendshipId) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    await _db.removeFriend(uid, friendUid, friendshipId);
  }

  Future<UserModel?> searchByUsername(String username) async {
    return _db.getUserByUsername(username);
  }

  bool isFriend(String uid) =>
      _currentUser?.friendIds.contains(uid) ?? false;

  bool hasPendingRequest(String uid) =>
      _friendships.any(
        (f) =>
            f.isPending &&
            ((f.user1 == _currentUser?.uid && f.user2 == uid) ||
                (f.user2 == _currentUser?.uid && f.user1 == uid)),
      );

  String? friendshipIdWith(String uid) {
    try {
      return _friendships
          .firstWhere(
            (f) =>
                (f.user1 == _currentUser?.uid && f.user2 == uid) ||
                (f.user2 == _currentUser?.uid && f.user1 == uid),
          )
          .id;
    } catch (_) {
      return null;
    }
  }
}

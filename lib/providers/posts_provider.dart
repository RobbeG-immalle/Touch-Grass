import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:touch_grass/models/post_model.dart';
import 'package:touch_grass/models/user_model.dart';
import 'package:touch_grass/services/database_service.dart';
import 'package:touch_grass/services/storage_service.dart';

class PostsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final StorageService _storage = StorageService();

  UserModel? _currentUser;
  List<PostModel> _feed = [];
  List<PostModel> _userPosts = [];
  List<PostModel> _publicPosts = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get feed => _feed;
  List<PostModel> get userPosts => _userPosts;
  List<PostModel> get publicPosts => _publicPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      _subscribeToFeed();
      _subscribeToUserPosts();
    }
  }

  void _subscribeToFeed() {
    final user = _currentUser;
    if (user == null) return;
    final ids = [...user.friendIds, user.uid];
    _db.feedStream(ids).listen((posts) {
      _feed = posts;
      notifyListeners();
    });
  }

  void _subscribeToUserPosts() {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    _db.userPostsStream(uid).listen((posts) {
      _userPosts = posts;
      notifyListeners();
    });
  }

  void subscribeToPublicPosts() {
    _db.publicPostsStream().listen((posts) {
      _publicPosts = posts;
      notifyListeners();
    });
  }

  Future<bool> createPost({
    required File imageFile,
    required String caption,
    required String visibility,
    double? latitude,
    double? longitude,
    String locationName = '',
  }) async {
    final uid = _currentUser?.uid;
    if (uid == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final imageUrl = await _storage.uploadPostImage(uid, imageFile);
      final post = PostModel(
        postId: '',
        userId: uid,
        imageUrl: imageUrl,
        caption: caption,
        visibility: visibility,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        createdAt: DateTime.now(),
      );
      await _db.createPost(post);
      await _db.recordPost(uid, _currentUser?.currentStreak ?? 0);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleLike(String postId) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    final post = _feed.firstWhere(
      (p) => p.postId == postId,
      orElse: () => _userPosts.firstWhere((p) => p.postId == postId),
    );
    final liked = !post.likedBy.contains(uid);
    await _db.toggleLike(postId, uid, liked);
  }

  Future<void> deletePost(String postId, String imageUrl) async {
    await _db.deletePost(postId);
    await _storage.deleteFile(imageUrl);
  }
}

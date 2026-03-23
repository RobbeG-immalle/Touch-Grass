import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:touch_grass/models/comment_model.dart';
import 'package:touch_grass/models/post_model.dart';
import 'package:touch_grass/models/user_model.dart';
import 'package:touch_grass/services/database_service.dart';
import 'package:touch_grass/services/storage_service.dart';

class PostsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final StorageService _storage = StorageService();

  UserModel? _currentUser;
  String? _subscribedUid;
  StreamSubscription<List<PostModel>>? _feedSub;
  StreamSubscription<List<PostModel>>? _userPostsSub;
  StreamSubscription<List<PostModel>>? _publicPostsSub;
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
    final newUid = user?.uid;
    if (newUid == _subscribedUid) {
      _currentUser = user;
      return;
    }
    _currentUser = user;
    _subscribedUid = newUid;
    if (user != null) {
      _subscribeToFeed();
      _subscribeToUserPosts();
    } else {
      _feedSub?.cancel();
      _userPostsSub?.cancel();
      _publicPostsSub?.cancel();
      _feedSub = null;
      _userPostsSub = null;
      _publicPostsSub = null;
      _feed = [];
      _userPosts = [];
      _publicPosts = [];
      notifyListeners();
    }
  }

  void _subscribeToFeed() {
    _feedSub?.cancel();
    final user = _currentUser;
    if (user == null) return;
    final ids = [...user.friendIds, user.uid];
    _feedSub = _db.feedStream(ids).listen(
      (posts) {
        _feed = posts;
        _error = null;
        notifyListeners();
      },
      onError: _handleStreamError,
    );
  }

  void _subscribeToUserPosts() {
    _userPostsSub?.cancel();
    final uid = _currentUser?.uid;
    if (uid == null) return;
    _userPostsSub = _db.userPostsStream(uid).listen(
      (posts) {
        _userPosts = posts;
        _error = null;
        notifyListeners();
      },
      onError: _handleStreamError,
    );
  }

  void subscribeToPublicPosts() {
    _publicPostsSub?.cancel();
    _publicPostsSub = _db.publicPostsStream().listen(
      (posts) {
        _publicPosts = posts;
        _error = null;
        notifyListeners();
      },
      onError: _handleStreamError,
    );
  }

  void _handleStreamError(Object error) {
    if (error is FirebaseException &&
        error.code == 'failed-precondition' &&
        (error.message?.toLowerCase().contains('index') ?? false)) {
      _error =
          'Feed query needs a Firestore index. Deploy firestore indexes and try again.';
    } else {
      _error = error.toString();
    }
    notifyListeners();
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
        username: _currentUser?.username ?? '',
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

    PostModel? post;
    for (final p in _feed) {
      if (p.postId == postId) { post = p; break; }
    }
    post ??= _userPosts.cast<PostModel?>().firstWhere(
      (p) => p!.postId == postId,
      orElse: () => _publicPosts.cast<PostModel?>().firstWhere(
        (p) => p!.postId == postId,
        orElse: () => null,
      ),
    );
    if (post == null) return;

    final liked = !post.likedBy.contains(uid);
    await _db.toggleLike(postId, uid, liked);
  }

  /// Find a post by ID from the local caches.
  PostModel? findPostById(String postId) {
    for (final p in _feed) {
      if (p.postId == postId) return p;
    }
    for (final p in _userPosts) {
      if (p.postId == postId) return p;
    }
    for (final p in _publicPosts) {
      if (p.postId == postId) return p;
    }
    return null;
  }

  /// Real-time stream for a single post.
  Stream<PostModel?> postStream(String postId) => _db.postStream(postId);

  /// Real-time stream of comments for a post.
  Stream<List<CommentModel>> commentsStream(String postId) =>
      _db.commentsStream(postId);

  /// Add a comment to a post.
  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    final comment = CommentModel(
      commentId: '',
      postId: postId,
      userId: uid,
      username: _currentUser?.username ?? '',
      text: text,
      createdAt: DateTime.now(),
    );
    await _db.addComment(comment);
  }

  Future<void> deletePost(String postId, String imageUrl) async {
    await _db.deletePost(postId);
    await _storage.deleteFile(imageUrl);
  }
}

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touch_grass/config/constants.dart';
import 'package:touch_grass/models/comment_model.dart';
import 'package:touch_grass/models/friendship_model.dart';
import 'package:touch_grass/models/post_model.dart';
import 'package:touch_grass/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── User ──────────────────────────────────────────────────────────────────

  Future<void> createUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toFirestore());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final query =
        await _db
            .collection(AppConstants.usersCollection)
            .where('username', isEqualTo: username)
            .limit(1)
            .get();
    if (query.docs.isEmpty) return null;
    return UserModel.fromFirestore(query.docs.first);
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection(AppConstants.usersCollection).doc(uid).delete();
  }

  // ── Posts ─────────────────────────────────────────────────────────────────

  Future<String> createPost(PostModel post) async {
    final doc = await _db
        .collection(AppConstants.postsCollection)
        .add(post.toFirestore());
    return doc.id;
  }

  Stream<List<PostModel>> feedStream(List<String> friendIds) {
    if (friendIds.isEmpty) {
      return Stream.value([]);
    }

    // Firestore whereIn supports at most 30 elements.
    const whereInLimit = 30;

    if (friendIds.length <= whereInLimit) {
      return _feedQuery(friendIds);
    }

    // Split into chunks of 30 and merge the snapshot streams.
    final chunks = <List<String>>[];
    for (var i = 0; i < friendIds.length; i += whereInLimit) {
      chunks.add(
        friendIds.sublist(i, min(i + whereInLimit, friendIds.length)),
      );
    }

    final streams = chunks.map(_feedQuery).toList();
    return _combinePostStreams(streams);
  }

  Stream<List<PostModel>> _feedQuery(List<String> ids) {
    return _db
        .collection(AppConstants.postsCollection)
        .where('userId', whereIn: ids)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.feedPageSize)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => PostModel.fromFirestore(d)).toList(),
        );
  }

  static Stream<List<PostModel>> _combinePostStreams(
    List<Stream<List<PostModel>>> streams,
  ) {
    final controller = StreamController<List<PostModel>>();
    final latest = List<List<PostModel>>.generate(
      streams.length,
      (_) => <PostModel>[],
    );
    final subs = <StreamSubscription<List<PostModel>>>[];
    var activeCount = streams.length;

    void emit() {
      final combined = latest.expand((e) => e).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(combined.take(AppConstants.feedPageSize).toList());
    }

    for (var i = 0; i < streams.length; i++) {
      final index = i;
      subs.add(
        streams[index].listen(
          (posts) {
            latest[index] = posts;
            emit();
          },
          onError: controller.addError,
          onDone: () {
            activeCount--;
            if (activeCount == 0) controller.close();
          },
        ),
      );
    }

    controller.onCancel = () {
      for (final sub in subs) {
        sub.cancel();
      }
    };

    return controller.stream;
  }

  Stream<List<PostModel>> publicPostsStream() {
    return _db
        .collection(AppConstants.postsCollection)
        .where('visibility', isEqualTo: AppConstants.visibilityPublic)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.feedPageSize)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => PostModel.fromFirestore(d)).toList(),
        );
  }

  Stream<List<PostModel>> hotPicsStream({int days = 7}) {
    final since = DateTime.now().subtract(Duration(days: days));
    return _db
        .collection(AppConstants.postsCollection)
        .where('visibility', isEqualTo: AppConstants.visibilityPublic)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.hotPicsPageSize)
        .snapshots()
        .map((snap) {
          final posts =
              snap.docs.map((d) => PostModel.fromFirestore(d)).toList();
          posts.sort((a, b) => b.likes.compareTo(a.likes));
          return posts;
        });
  }

  Stream<List<PostModel>> userPostsStream(String uid) {
    return _db
        .collection(AppConstants.postsCollection)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => PostModel.fromFirestore(d)).toList(),
        );
  }

  Future<void> toggleLike(String postId, String uid, bool liked) async {
    final ref = _db.collection(AppConstants.postsCollection).doc(postId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final List<String> likedBy = List<String>.from(
        snap.data()?['likedBy'] as List? ?? [],
      );
      if (liked) {
        likedBy.add(uid);
      } else {
        likedBy.remove(uid);
      }
      tx.update(ref, {'likedBy': likedBy, 'likes': likedBy.length});
    });
  }

  Future<void> deletePost(String postId) async {
    await _db.collection(AppConstants.postsCollection).doc(postId).delete();
  }

  // ── Comments ──────────────────────────────────────────────────────────────

  Stream<List<CommentModel>> commentsStream(String postId) {
    return _db
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .collection(AppConstants.commentsCollection)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => CommentModel.fromFirestore(d, postId))
              .toList(),
        );
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    final postRef =
        _db.collection(AppConstants.postsCollection).doc(postId);
    final commentRef =
        postRef.collection(AppConstants.commentsCollection).doc();
    final batch = _db.batch()
      ..set(commentRef, comment.toFirestore())
      ..update(postRef, {'commentCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final postRef =
        _db.collection(AppConstants.postsCollection).doc(postId);
    final commentRef =
        postRef.collection(AppConstants.commentsCollection).doc(commentId);
    final batch = _db.batch()
      ..delete(commentRef)
      ..update(postRef, {'commentCount': FieldValue.increment(-1)});
    await batch.commit();
  }

  // ── Streak ────────────────────────────────────────────────────────────────

  /// Returns the new streak value without modifying Firestore.
  static int calculateNewStreak(int currentStreak, DateTime? lastPostDate) {
    final today = _today();
    if (lastPostDate == null) return 1;
    final last = _dateOnly(lastPostDate);
    if (last == today) return currentStreak; // already posted today
    if (today.difference(last).inDays == 1) return currentStreak + 1;
    return 1; // streak broken
  }

  static bool shouldIncrementStreak(DateTime? lastPostDate, DateTime now) {
    if (lastPostDate == null) return true;
    final last = _dateOnly(lastPostDate);
    final today = _dateOnly(now);
    return today.difference(last).inDays == 1;
  }

  static bool isStreakBroken(DateTime? lastPostDate, DateTime now) {
    if (lastPostDate == null) return false;
    final last = _dateOnly(lastPostDate);
    final today = _dateOnly(now);
    return today.difference(last).inDays >= 2;
  }

  static DateTime _today() => _dateOnly(DateTime.now());

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  Future<void> recordPost(String uid, int currentStreak) async {
    final now = DateTime.now();
    final user = await getUser(uid);
    final newStreak = calculateNewStreak(currentStreak, user?.lastPostDate);
    final longest = newStreak > (user?.longestStreak ?? 0)
        ? newStreak
        : (user?.longestStreak ?? 0);
    await updateUser(uid, {
      'lastPostDate': Timestamp.fromDate(now),
      'currentStreak': newStreak,
      'longestStreak': longest,
    });
  }

  // ── Friendships ───────────────────────────────────────────────────────────

  Future<void> sendFriendRequest({
    required String fromUid,
    required String toUid,
  }) async {
    final friendship = FriendshipModel(
      id: '',
      user1: fromUid,
      user2: toUid,
      status: AppConstants.friendshipPending,
      requestedBy: fromUid,
      createdAt: DateTime.now(),
    );
    await _db
        .collection(AppConstants.friendshipsCollection)
        .add(friendship.toFirestore());
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    final ref = _db
        .collection(AppConstants.friendshipsCollection)
        .doc(friendshipId);
    final snap = await ref.get();
    final data = snap.data()!;
    final u1 = data['user1'] as String;
    final u2 = data['user2'] as String;

    await _db.runTransaction((tx) async {
      tx.update(ref, {'status': AppConstants.friendshipAccepted});
      tx.update(
        _db.collection(AppConstants.usersCollection).doc(u1),
        {
          'friendIds': FieldValue.arrayUnion([u2]),
        },
      );
      tx.update(
        _db.collection(AppConstants.usersCollection).doc(u2),
        {
          'friendIds': FieldValue.arrayUnion([u1]),
        },
      );
    });
  }

  Future<void> removeFriend(
    String uid,
    String friendUid,
    String friendshipId,
  ) async {
    await _db.runTransaction((tx) async {
      tx.delete(
        _db
            .collection(AppConstants.friendshipsCollection)
            .doc(friendshipId),
      );
      tx.update(
        _db.collection(AppConstants.usersCollection).doc(uid),
        {
          'friendIds': FieldValue.arrayRemove([friendUid]),
        },
      );
      tx.update(
        _db.collection(AppConstants.usersCollection).doc(friendUid),
        {
          'friendIds': FieldValue.arrayRemove([uid]),
        },
      );
    });
  }

  Stream<List<FriendshipModel>> friendshipsStream(String uid) {
    return _db
        .collection(AppConstants.friendshipsCollection)
        .where(
          Filter.or(
            Filter('user1', isEqualTo: uid),
            Filter('user2', isEqualTo: uid),
          ),
        )
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => FriendshipModel.fromFirestore(d))
              .toList(),
        );
  }
}

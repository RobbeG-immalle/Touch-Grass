import 'package:test/test.dart';
import 'package:touch_grass/models/post_model.dart';

void main() {
  final testDate = DateTime(2024, 6, 15, 12, 0);

  group('PostModel.toMap / fromMap round-trip', () {
    test('serializes and deserializes a full post', () {
      final original = PostModel(
        postId: 'post_abc123',
        userId: 'user_xyz',
        imageUrl: 'https://example.com/image.jpg',
        caption: 'Touching grass today! 🌿',
        visibility: 'public',
        latitude: 37.7749,
        longitude: -122.4194,
        locationName: 'Golden Gate Park',
        likes: 42,
        likedBy: ['user_a', 'user_b', 'user_c'],
        commentCount: 3,
        createdAt: testDate,
      );

      final map = original.toMap();
      final restored = PostModel.fromMap(map, 'post_abc123');

      expect(restored.postId, equals(original.postId));
      expect(restored.userId, equals(original.userId));
      expect(restored.imageUrl, equals(original.imageUrl));
      expect(restored.imageUrls, equals(original.imageUrls));
      expect(restored.caption, equals(original.caption));
      expect(restored.visibility, equals(original.visibility));
      expect(restored.latitude, equals(original.latitude));
      expect(restored.longitude, equals(original.longitude));
      expect(restored.locationName, equals(original.locationName));
      expect(restored.likes, equals(original.likes));
      expect(restored.likedBy, equals(original.likedBy));
      expect(restored.commentCount, equals(original.commentCount));
      expect(restored.createdAt, equals(original.createdAt));
    });

    test('serializes and deserializes a post with multiple images', () {
      final original = PostModel(
        postId: 'multi_post',
        userId: 'user_xyz',
        imageUrls: [
          'https://example.com/img1.jpg',
          'https://example.com/img2.jpg',
          'https://example.com/img3.jpg',
        ],
        createdAt: testDate,
      );

      final map = original.toMap();
      final restored = PostModel.fromMap(map, 'multi_post');

      expect(restored.imageUrls, hasLength(3));
      expect(restored.imageUrl, equals('https://example.com/img1.jpg'));
    });

    test('handles missing optional fields with defaults', () {
      final minimal = PostModel(
        postId: 'min_post',
        userId: 'user_1',
        imageUrl: 'https://example.com/img.jpg',
        createdAt: testDate,
      );

      final map = minimal.toMap();
      final restored = PostModel.fromMap(map, 'min_post');

      expect(restored.caption, equals(''));
      expect(restored.visibility, equals('friends'));
      expect(restored.latitude, isNull);
      expect(restored.longitude, isNull);
      expect(restored.locationName, equals(''));
      expect(restored.likes, equals(0));
      expect(restored.likedBy, isEmpty);
      expect(restored.commentCount, equals(0));
    });

    test('legacy single imageUrl is wrapped into imageUrls list', () {
      // Simulate a Firestore document that only has imageUrl (no imageUrls).
      final legacyMap = {
        'userId': 'u1',
        'username': '',
        'imageUrl': 'https://example.com/legacy.jpg',
        'caption': '',
        'visibility': 'friends',
        'likes': 0,
        'likedBy': <String>[],
        'commentCount': 0,
        'createdAt': testDate,
      };
      final restored = PostModel.fromMap(legacyMap, 'legacy');
      expect(restored.imageUrls, hasLength(1));
      expect(restored.imageUrl, equals('https://example.com/legacy.jpg'));
    });

    test('hasLocation returns true when lat/lng are set', () {
      final post = PostModel(
        postId: 'p1',
        userId: 'u1',
        imageUrl: 'https://example.com/img.jpg',
        latitude: 51.5074,
        longitude: -0.1278,
        createdAt: testDate,
      );
      expect(post.hasLocation, isTrue);
    });

    test('hasLocation returns false when lat/lng are null', () {
      final post = PostModel(
        postId: 'p2',
        userId: 'u1',
        imageUrl: 'https://example.com/img.jpg',
        createdAt: testDate,
      );
      expect(post.hasLocation, isFalse);
    });
  });

  group('PostModel.copyWith', () {
    final base = PostModel(
      postId: 'base_post',
      userId: 'user_1',
      imageUrl: 'https://example.com/img.jpg',
      caption: 'Original caption',
      likes: 5,
      likedBy: ['user_a'],
      createdAt: testDate,
    );

    test('copies with changed likes', () {
      final updated = base.copyWith(likes: 10);
      expect(updated.likes, equals(10));
      expect(updated.caption, equals(base.caption));
    });

    test('copies with changed likedBy list', () {
      final updated = base.copyWith(likedBy: ['user_a', 'user_b']);
      expect(updated.likedBy, hasLength(2));
      expect(updated.likedBy, contains('user_b'));
    });

    test('copies with visibility change', () {
      final updated = base.copyWith(visibility: 'public');
      expect(updated.visibility, equals('public'));
      expect(updated.postId, equals(base.postId));
    });

    test('copies with updated imageUrls', () {
      final updated = base.copyWith(imageUrls: [
        'https://example.com/new1.jpg',
        'https://example.com/new2.jpg',
      ]);
      expect(updated.imageUrls, hasLength(2));
      expect(updated.imageUrl, equals('https://example.com/new1.jpg'));
    });

    test('copies with updated commentCount', () {
      final updated = base.copyWith(commentCount: 7);
      expect(updated.commentCount, equals(7));
    });

    test('preserves all fields not in copyWith call', () {
      final updated = base.copyWith(caption: 'New caption');
      expect(updated.postId, equals(base.postId));
      expect(updated.userId, equals(base.userId));
      expect(updated.imageUrl, equals(base.imageUrl));
      expect(updated.likes, equals(base.likes));
      expect(updated.createdAt, equals(base.createdAt));
    });
  });

  group('PostModel visibility', () {
    test('defaults to friends visibility', () {
      final post = PostModel(
        postId: 'p',
        userId: 'u',
        imageUrl: 'url',
        createdAt: testDate,
      );
      expect(post.visibility, equals('friends'));
    });

    test('can be set to public', () {
      final post = PostModel(
        postId: 'p',
        userId: 'u',
        imageUrl: 'url',
        visibility: 'public',
        createdAt: testDate,
      );
      expect(post.visibility, equals('public'));
    });
  });

  group('PostModel maxImages', () {
    test('maxImages constant is 5', () {
      expect(PostModel.maxImages, equals(5));
    });
  });
}


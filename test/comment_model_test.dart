import 'package:test/test.dart';
import 'package:touch_grass/models/comment_model.dart';

void main() {
  final testDate = DateTime(2024, 6, 15, 12, 0);

  group('CommentModel.toMap / fromMap round-trip', () {
    test('serializes and deserializes a comment', () {
      final original = CommentModel(
        commentId: 'comment_abc123',
        postId: 'post_xyz',
        userId: 'user_1',
        username: 'alice',
        text: 'Great photo! 🌿',
        createdAt: testDate,
      );

      final map = original.toMap();
      final restored = CommentModel.fromMap(map, 'comment_abc123');

      expect(restored.commentId, equals(original.commentId));
      expect(restored.postId, equals(original.postId));
      expect(restored.userId, equals(original.userId));
      expect(restored.username, equals(original.username));
      expect(restored.text, equals(original.text));
      expect(restored.createdAt, equals(original.createdAt));
    });

    test('handles missing optional fields with defaults', () {
      final minimal = CommentModel(
        commentId: 'c1',
        postId: 'p1',
        userId: 'u1',
        text: 'Nice!',
        createdAt: testDate,
      );

      final map = minimal.toMap();
      final restored = CommentModel.fromMap(map, 'c1');

      expect(restored.username, equals(''));
      expect(restored.text, equals('Nice!'));
    });

    test('fromMap handles missing keys gracefully', () {
      final map = <String, dynamic>{};
      final comment = CommentModel.fromMap(map, 'fallback_id');

      expect(comment.commentId, equals('fallback_id'));
      expect(comment.postId, equals(''));
      expect(comment.userId, equals(''));
      expect(comment.username, equals(''));
      expect(comment.text, equals(''));
    });
  });
}

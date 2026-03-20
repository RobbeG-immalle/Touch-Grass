import 'package:test/test.dart';
import 'package:touch_grass/services/database_service.dart';

void main() {
  group('DatabaseService.shouldIncrementStreak', () {
    test('returns true when lastPostDate is null', () {
      expect(
        DatabaseService.shouldIncrementStreak(null, DateTime.now()),
        isTrue,
      );
    });

    test('returns true when last post was yesterday', () {
      final now = DateTime(2024, 6, 15, 10, 0);
      final yesterday = DateTime(2024, 6, 14, 18, 30);
      expect(
        DatabaseService.shouldIncrementStreak(yesterday, now),
        isTrue,
      );
    });

    test('returns false when last post was today', () {
      final now = DateTime(2024, 6, 15, 10, 0);
      final todayEarlier = DateTime(2024, 6, 15, 8, 0);
      expect(
        DatabaseService.shouldIncrementStreak(todayEarlier, now),
        isFalse,
      );
    });

    test('returns false when last post was 2 days ago', () {
      final now = DateTime(2024, 6, 15, 10, 0);
      final twoDaysAgo = DateTime(2024, 6, 13, 10, 0);
      expect(
        DatabaseService.shouldIncrementStreak(twoDaysAgo, now),
        isFalse,
      );
    });

    test('returns false when last post was a week ago', () {
      final now = DateTime(2024, 6, 15);
      final weekAgo = DateTime(2024, 6, 8);
      expect(
        DatabaseService.shouldIncrementStreak(weekAgo, now),
        isFalse,
      );
    });
  });

  group('DatabaseService.isStreakBroken', () {
    test('returns false when lastPostDate is null', () {
      expect(
        DatabaseService.isStreakBroken(null, DateTime.now()),
        isFalse,
      );
    });

    test('returns false when last post was yesterday', () {
      final now = DateTime(2024, 6, 15, 10, 0);
      final yesterday = DateTime(2024, 6, 14, 18, 0);
      expect(
        DatabaseService.isStreakBroken(yesterday, now),
        isFalse,
      );
    });

    test('returns false when last post was today', () {
      final now = DateTime(2024, 6, 15, 10, 0);
      final today = DateTime(2024, 6, 15, 7, 0);
      expect(
        DatabaseService.isStreakBroken(today, now),
        isFalse,
      );
    });

    test('returns true when last post was 2 days ago', () {
      final now = DateTime(2024, 6, 15, 10, 0);
      final twoDaysAgo = DateTime(2024, 6, 13, 10, 0);
      expect(
        DatabaseService.isStreakBroken(twoDaysAgo, now),
        isTrue,
      );
    });

    test('returns true when last post was 30 days ago', () {
      final now = DateTime(2024, 6, 15);
      final monthAgo = DateTime(2024, 5, 15);
      expect(
        DatabaseService.isStreakBroken(monthAgo, now),
        isTrue,
      );
    });
  });

  group('DatabaseService.calculateNewStreak', () {
    test('starts at 1 when no previous post', () {
      expect(DatabaseService.calculateNewStreak(0, null), equals(1));
    });

    test('increments streak when last post was yesterday', () {
      // We call the static method directly; it uses DateTime.now() internally
      // for the "today" reference. We test the static helpers instead.
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = DatabaseService.calculateNewStreak(5, yesterday);
      expect(result, equals(6));
    });

    test('keeps streak when last post was today', () {
      final today = DateTime.now();
      final result = DatabaseService.calculateNewStreak(5, today);
      expect(result, equals(5));
    });

    test('resets streak to 1 when last post was 2+ days ago', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final result = DatabaseService.calculateNewStreak(10, twoDaysAgo);
      expect(result, equals(1));
    });

    test('resets streak to 1 after long absence', () {
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));
      final result = DatabaseService.calculateNewStreak(42, monthAgo);
      expect(result, equals(1));
    });

    test('streak of 0 starts at 1 with null lastPostDate', () {
      expect(DatabaseService.calculateNewStreak(0, null), equals(1));
    });
  });
}

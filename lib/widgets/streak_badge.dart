import 'package:flutter/material.dart';
import 'package:touch_grass/config/theme.dart';

/// Displays a user's current streak with a fire emoji and count.
class StreakBadge extends StatelessWidget {
  final int streak;

  /// When [compact] is true, shows a smaller inline version.
  final bool compact;

  const StreakBadge({super.key, required this.streak, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accentOrange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '$streak',
              style: const TextStyle(
                color: AppTheme.accentOrange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          streak > 0 ? '🔥' : '🌱',
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(height: 2),
        Text(
          '$streak',
          style: const TextStyle(
            color: AppTheme.accentOrange,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          streak == 1 ? 'day' : 'days',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

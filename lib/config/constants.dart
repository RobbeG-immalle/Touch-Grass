class AppConstants {
  AppConstants._();

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String friendshipsCollection = 'friendships';
  static const String commentsCollection = 'comments';

  // Visibility options
  static const String visibilityFriends = 'friends';
  static const String visibilityPublic = 'public';

  // Friendship statuses
  static const String friendshipPending = 'pending';
  static const String friendshipAccepted = 'accepted';

  // Default notification time
  static const String defaultNotificationTime = '09:00';

  // Storage paths
  static const String avatarsPath = 'avatars';
  static const String postsPath = 'posts';

  // Streak notification channel
  static const String notificationChannelId = 'touch_grass_daily';
  static const String notificationChannelName = 'Daily Reminder';
  static const int dailyNotificationId = 42;

  // SharedPreferences keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefNotificationTime = 'notification_time';
  static const String prefDefaultVisibility = 'default_visibility';

  // Pagination
  static const int feedPageSize = 20;
  static const int hotPicsPageSize = 30;

  // Map defaults
  static const double defaultMapLat = 37.7749;
  static const double defaultMapLng = -122.4194;
  static const double defaultMapZoom = 10.0;
}

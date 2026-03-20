import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touch_grass/config/constants.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String avatarUrl;
  final String bio;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPostDate;
  final bool notificationEnabled;
  final String notificationTime;
  final String defaultVisibility;
  final DateTime createdAt;
  final List<String> friendIds;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.avatarUrl = '',
    this.bio = '',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPostDate,
    this.notificationEnabled = true,
    this.notificationTime = AppConstants.defaultNotificationTime,
    this.defaultVisibility = AppConstants.visibilityFriends,
    required this.createdAt,
    this.friendIds = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastPostDate: (data['lastPostDate'] as Timestamp?)?.toDate(),
      notificationEnabled: data['notificationEnabled'] as bool? ?? true,
      notificationTime:
          data['notificationTime'] as String? ??
          AppConstants.defaultNotificationTime,
      defaultVisibility:
          data['defaultVisibility'] as String? ??
          AppConstants.visibilityFriends,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      friendIds: List<String>.from(data['friendIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'username': username,
    'email': email,
    'avatarUrl': avatarUrl,
    'bio': bio,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastPostDate':
        lastPostDate != null ? Timestamp.fromDate(lastPostDate!) : null,
    'notificationEnabled': notificationEnabled,
    'notificationTime': notificationTime,
    'defaultVisibility': defaultVisibility,
    'createdAt': Timestamp.fromDate(createdAt),
    'friendIds': friendIds,
  };

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastPostDate,
    bool? notificationEnabled,
    String? notificationTime,
    String? defaultVisibility,
    DateTime? createdAt,
    List<String>? friendIds,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPostDate: lastPostDate ?? this.lastPostDate,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      defaultVisibility: defaultVisibility ?? this.defaultVisibility,
      createdAt: createdAt ?? this.createdAt,
      friendIds: friendIds ?? this.friendIds,
    );
  }
}

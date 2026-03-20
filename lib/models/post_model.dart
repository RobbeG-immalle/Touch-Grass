import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String imageUrl;
  final String caption;
  final String visibility;
  final double? latitude;
  final double? longitude;
  final String locationName;
  final int likes;
  final List<String> likedBy;
  final DateTime createdAt;

  const PostModel({
    required this.postId,
    required this.userId,
    required this.imageUrl,
    this.caption = '',
    this.visibility = 'friends',
    this.latitude,
    this.longitude,
    this.locationName = '',
    this.likes = 0,
    this.likedBy = const [],
    required this.createdAt,
  });

  bool get hasLocation => latitude != null && longitude != null;

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id,
      userId: data['userId'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      visibility: data['visibility'] as String? ?? 'friends',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      locationName: data['locationName'] as String? ?? '',
      likes: data['likes'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory PostModel.fromMap(Map<String, dynamic> data, String id) {
    return PostModel(
      postId: id,
      userId: data['userId'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      visibility: data['visibility'] as String? ?? 'friends',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      locationName: data['locationName'] as String? ?? '',
      likes: data['likes'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
      createdAt:
          data['createdAt'] is DateTime
              ? data['createdAt'] as DateTime
              : (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'imageUrl': imageUrl,
    'caption': caption,
    'visibility': visibility,
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
    'likes': likes,
    'likedBy': likedBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'imageUrl': imageUrl,
    'caption': caption,
    'visibility': visibility,
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
    'likes': likes,
    'likedBy': likedBy,
    'createdAt': createdAt,
  };

  PostModel copyWith({
    String? postId,
    String? userId,
    String? imageUrl,
    String? caption,
    String? visibility,
    double? latitude,
    double? longitude,
    String? locationName,
    int? likes,
    List<String>? likedBy,
    DateTime? createdAt,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      visibility: visibility ?? this.visibility,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

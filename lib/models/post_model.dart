import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String username;
  final List<String> imageUrls;
  final String caption;
  final String visibility;
  final double? latitude;
  final double? longitude;
  final String locationName;
  final int likes;
  final List<String> likedBy;
  final int commentCount;
  final DateTime createdAt;

  /// Convenience getter – returns the first image URL (backwards compat).
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  static const int maxImages = 5;

  PostModel({
    required this.postId,
    required this.userId,
    this.username = '',
    // Accept a legacy single URL or a list. The list takes precedence.
    String imageUrl = '',
    List<String> imageUrls = const [],
    this.caption = '',
    this.visibility = 'friends',
    this.latitude,
    this.longitude,
    this.locationName = '',
    this.likes = 0,
    this.likedBy = const [],
    this.commentCount = 0,
    required this.createdAt,
  }) : imageUrls =
           imageUrls.isNotEmpty
               ? imageUrls
               : (imageUrl.isNotEmpty ? [imageUrl] : const []);

  bool get hasLocation => latitude != null && longitude != null;

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawUrls = data['imageUrls'];
    final List<String> urls =
        rawUrls != null
            ? List<String>.from(rawUrls as List)
            : _singleUrl(data['imageUrl'] as String? ?? '');
    return PostModel(
      postId: doc.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      imageUrls: urls,
      caption: data['caption'] as String? ?? '',
      visibility: data['visibility'] as String? ?? 'friends',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      locationName: data['locationName'] as String? ?? '',
      likes: data['likes'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
      commentCount: data['commentCount'] as int? ?? 0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory PostModel.fromMap(Map<String, dynamic> data, String id) {
    final rawUrls = data['imageUrls'];
    final List<String> urls =
        rawUrls != null
            ? List<String>.from(rawUrls as List)
            : _singleUrl(data['imageUrl'] as String? ?? '');
    return PostModel(
      postId: id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      imageUrls: urls,
      caption: data['caption'] as String? ?? '',
      visibility: data['visibility'] as String? ?? 'friends',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      locationName: data['locationName'] as String? ?? '',
      likes: data['likes'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
      commentCount: data['commentCount'] as int? ?? 0,
      createdAt:
          data['createdAt'] is DateTime
              ? data['createdAt'] as DateTime
              : (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'username': username,
    'imageUrl': imageUrl, // kept for backwards compat with old clients
    'imageUrls': imageUrls,
    'caption': caption,
    'visibility': visibility,
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
    'likes': likes,
    'likedBy': likedBy,
    'commentCount': commentCount,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'username': username,
    'imageUrl': imageUrl, // kept for backwards compat
    'imageUrls': imageUrls,
    'caption': caption,
    'visibility': visibility,
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
    'likes': likes,
    'likedBy': likedBy,
    'commentCount': commentCount,
    'createdAt': createdAt,
  };

  PostModel copyWith({
    String? postId,
    String? userId,
    String? username,
    List<String>? imageUrls,
    String? caption,
    String? visibility,
    double? latitude,
    double? longitude,
    String? locationName,
    int? likes,
    List<String>? likedBy,
    int? commentCount,
    DateTime? createdAt,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      visibility: visibility ?? this.visibility,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<String> _singleUrl(String url) =>
      url.isNotEmpty ? [url] : const [];
}

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    this.username = '',
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      commentId: doc.id,
      postId: data['postId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory CommentModel.fromMap(Map<String, dynamic> data, String id) {
    return CommentModel(
      commentId: id,
      postId: data['postId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt:
          data['createdAt'] is DateTime
              ? data['createdAt'] as DateTime
              : (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'postId': postId,
    'userId': userId,
    'username': username,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Map<String, dynamic> toMap() => {
    'postId': postId,
    'userId': userId,
    'username': username,
    'text': text,
    'createdAt': createdAt,
  };
}

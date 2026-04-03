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

  factory CommentModel.fromFirestore(DocumentSnapshot doc, String postId) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      commentId: doc.id,
      postId: postId,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'username': username,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

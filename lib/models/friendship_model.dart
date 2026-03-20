import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touch_grass/config/constants.dart';

class FriendshipModel {
  final String id;
  final String user1;
  final String user2;
  final String status;
  final String requestedBy;
  final DateTime createdAt;

  const FriendshipModel({
    required this.id,
    required this.user1,
    required this.user2,
    this.status = AppConstants.friendshipPending,
    required this.requestedBy,
    required this.createdAt,
  });

  bool get isPending => status == AppConstants.friendshipPending;
  bool get isAccepted => status == AppConstants.friendshipAccepted;

  factory FriendshipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendshipModel(
      id: doc.id,
      user1: data['user1'] as String? ?? '',
      user2: data['user2'] as String? ?? '',
      status: data['status'] as String? ?? AppConstants.friendshipPending,
      requestedBy: data['requestedBy'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'user1': user1,
    'user2': user2,
    'status': status,
    'requestedBy': requestedBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  FriendshipModel copyWith({
    String? id,
    String? user1,
    String? user2,
    String? status,
    String? requestedBy,
    DateTime? createdAt,
  }) {
    return FriendshipModel(
      id: id ?? this.id,
      user1: user1 ?? this.user1,
      user2: user2 ?? this.user2,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  NotificationType _typeFrom(String? raw) {
    return NotificationType.values.firstWhere(
      (t) => t.name == raw,
      orElse: () => NotificationType.unknown,
    );
  }

  AppNotification _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return AppNotification(
      id: doc.id,
      recipientId: data['recipientId'] as String? ?? '',
      actorId: data['actorId'] as String? ?? '',
      type: _typeFrom(data['type'] as String?),
      decisionId: data['decisionId'] as String?,
      read: data['read'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Stream<List<AppNotification>> watchNotifications(String recipientId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: recipientId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({'read': true});
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('markAsRead failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }
}

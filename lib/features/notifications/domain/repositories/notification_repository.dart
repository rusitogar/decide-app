import '../../../../core/error/result.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Stream<List<AppNotification>> watchNotifications(String recipientId);

  Future<Result<void>> markAsRead(String notificationId);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => NotificationRepositoryImpl());

final notificationsProvider = StreamProvider.autoDispose.family<List<AppNotification>, String>(
  (ref, recipientId) => ref.watch(notificationRepositoryProvider).watchNotifications(recipientId),
);

class NotificationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markAsRead(String notificationId) async {
    await ref.read(notificationRepositoryProvider).markAsRead(notificationId);
  }
}

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, void>(NotificationController.new);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../users/presentation/providers/user_providers.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key, required this.userId});

  final String userId;

  String _label(NotificationType type) {
    return switch (type) {
      NotificationType.vote => 'votó tu decisión',
      NotificationType.comment => 'comentó tu decisión',
      NotificationType.follow => 'empezó a seguirte',
      NotificationType.unknown => 'interactuó con vos',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('Todavía no tenés notificaciones.'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              final actorAsync = ref.watch(userProfileProvider(n.actorId));
              return actorAsync.when(
                data: (actor) => ListTile(
                  tileColor: n.read ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
                  title: Text(
                    '${actor?.displayName.isNotEmpty == true ? actor!.displayName : '@${actor?.username ?? ''}'} ${_label(n.type)}',
                  ),
                  onTap: () {
                    if (!n.read) {
                      ref.read(notificationControllerProvider.notifier).markAsRead(n.id);
                    }
                    if (n.decisionId != null) {
                      context.push('/decision/${n.decisionId}');
                    }
                  },
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

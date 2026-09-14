import 'package:equatable/equatable.dart';

enum NotificationType { vote, comment, follow, unknown }

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.actorId,
    required this.type,
    required this.decisionId,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String recipientId;
  final String actorId;
  final NotificationType type;
  final String? decisionId;
  final bool read;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, recipientId, actorId, type, decisionId, read, createdAt];
}

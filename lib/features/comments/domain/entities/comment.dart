import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.decisionId,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String decisionId;
  final String authorId;
  final String text;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, decisionId, authorId, text, createdAt];
}

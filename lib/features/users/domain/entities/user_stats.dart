import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  const UserStats({
    required this.decisionsCreated,
    required this.votesCast,
    required this.likesReceived,
    required this.commentsReceived,
    required this.topCategory,
  });

  final int decisionsCreated;
  final int votesCast;
  final int likesReceived;
  final int commentsReceived;

  /// Categoría más frecuente entre las decisiones que votó, o null si
  /// todavía no votó ninguna.
  final String? topCategory;

  @override
  List<Object?> get props => [decisionsCreated, votesCast, likesReceived, commentsReceived, topCategory];
}

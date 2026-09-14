import 'package:equatable/equatable.dart';

class DecisionStats extends Equatable {
  const DecisionStats({required this.votes, required this.comments, required this.likes});

  final int votes;
  final int comments;
  final int likes;

  @override
  List<Object?> get props => [votes, comments, likes];
}

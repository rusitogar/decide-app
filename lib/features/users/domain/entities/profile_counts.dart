import 'package:equatable/equatable.dart';

class ProfileCounts extends Equatable {
  const ProfileCounts({
    required this.followers,
    required this.following,
    required this.decisions,
  });

  final int followers;
  final int following;
  final int decisions;

  @override
  List<Object?> get props => [followers, following, decisions];
}

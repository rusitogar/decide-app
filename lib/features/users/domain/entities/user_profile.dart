import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.avatarColor,
  });

  final String uid;
  final String username;
  final String displayName;
  final String bio;
  final String avatarUrl;

  /// Color de fondo del avatar con iniciales, usado mientras no haya foto
  /// real (subir fotos requiere Firebase Storage, pendiente de Blaze).
  final int avatarColor;

  UserProfile copyWith({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    int? avatarColor,
  }) {
    return UserProfile(
      uid: uid,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }

  @override
  List<Object?> get props => [uid, username, displayName, bio, avatarUrl, avatarColor];
}

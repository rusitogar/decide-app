import 'package:flutter/material.dart';

import '../../domain/entities/user_profile.dart';

/// Iniciales para el avatar por defecto: hasta 2 letras, del nombre visible
/// o, si está vacío, del username.
String initialsFor({required String displayName, required String username}) {
  final source = displayName.trim().isNotEmpty ? displayName.trim() : username.trim();
  if (source.isEmpty) return '?';

  final words = source.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.length == 1) {
    return words.first.substring(0, words.first.length >= 2 ? 2 : 1).toUpperCase();
  }
  return (words[0][0] + words[1][0]).toUpperCase();
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.profile, this.radius = 32});

  final UserProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (profile.avatarUrl.isNotEmpty) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(profile.avatarUrl));
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(profile.avatarColor),
      child: Text(
        initialsFor(displayName: profile.displayName, username: profile.username),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

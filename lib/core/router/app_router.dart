import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_gate.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/users/presentation/screens/edit_profile_screen.dart';
import '../../features/users/presentation/screens/profile_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/:uid',
        builder: (context, state) => ProfileScreen(uid: state.pathParameters['uid']!),
      ),
      // Ruta usada para deep links de compartir: decide://decision/{id}
      // y https://decide.app/decision/{id} (Android App Links / iOS Universal Links).
      GoRoute(
        path: '/decision/:id',
        builder: (context, state) => _DecisionPlaceholderScreen(
          id: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});

class _DecisionPlaceholderScreen extends StatelessWidget {
  const _DecisionPlaceholderScreen({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Decisión $id')),
    );
  }
}

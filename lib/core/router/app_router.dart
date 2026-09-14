import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_gate.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/decisions/presentation/screens/create_decision_screen.dart';
import '../../features/decisions/presentation/screens/decision_detail_screen.dart';
import '../../features/decisions/presentation/screens/edit_decision_screen.dart';
import '../../features/decisions/presentation/screens/user_decisions_screen.dart';
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
        path: '/profile/:uid/decisions',
        builder: (context, state) => UserDecisionsScreen(uid: state.pathParameters['uid']!),
      ),
      GoRoute(
        path: '/profile/:uid',
        builder: (context, state) => ProfileScreen(uid: state.pathParameters['uid']!),
      ),
      GoRoute(
        path: '/decisions/create',
        builder: (context, state) => const CreateDecisionScreen(),
      ),
      // Ruta usada para deep links de compartir: decide://decision/{id}
      // y https://decide.app/decision/{id} (Android App Links / iOS Universal Links).
      GoRoute(
        path: '/decision/:id/edit',
        builder: (context, state) => EditDecisionScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/decision/:id',
        builder: (context, state) => DecisionDetailScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
});

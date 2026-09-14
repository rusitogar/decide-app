import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _HomePlaceholderScreen(),
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

class _HomePlaceholderScreen extends StatelessWidget {
  const _HomePlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('DECIDE')),
    );
  }
}

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

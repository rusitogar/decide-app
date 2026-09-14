import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../feed/presentation/widgets/feed_body.dart';
import '../providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DECIDE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Guardados',
            onPressed: user == null ? null : () => context.push('/saved/${user.uid}'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Mi perfil',
            onPressed: user == null ? null : () => context.push('/profile/${user.uid}'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: FeedBody(currentUid: user?.uid),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/decisions/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva decisión'),
      ),
    );
  }
}

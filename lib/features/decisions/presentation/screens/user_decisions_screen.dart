import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/decision_providers.dart';

class UserDecisionsScreen extends ConsumerWidget {
  const UserDecisionsScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisionsAsync = ref.watch(decisionsByAuthorProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Decisiones')),
      body: decisionsAsync.when(
        data: (decisions) {
          if (decisions.isEmpty) {
            return const Center(child: Text('Todavía no hay decisiones.'));
          }
          return ListView.builder(
            itemCount: decisions.length,
            itemBuilder: (context, index) {
              final decision = decisions[index];
              return ListTile(
                title: Text(decision.title),
                subtitle: decision.description.isNotEmpty ? Text(decision.description) : null,
                onTap: () => context.push('/decision/${decision.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

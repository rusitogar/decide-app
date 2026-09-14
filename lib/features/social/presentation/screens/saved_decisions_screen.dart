import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../decisions/presentation/providers/decision_providers.dart';
import '../providers/save_providers.dart';

class SavedDecisionsScreen extends ConsumerWidget {
  const SavedDecisionsScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idsAsync = ref.watch(savedDecisionIdsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Guardados')),
      body: idsAsync.when(
        data: (ids) {
          if (ids.isEmpty) {
            return const Center(child: Text('Todavía no guardaste ninguna decisión.'));
          }
          return ListView.builder(
            itemCount: ids.length,
            itemBuilder: (context, index) {
              final id = ids[index];
              final decisionAsync = ref.watch(decisionProvider(id));
              return decisionAsync.when(
                data: (decision) => decision == null
                    ? const SizedBox.shrink()
                    : ListTile(
                        title: Text(decision.title),
                        onTap: () => context.push('/decision/$id'),
                      ),
                loading: () => const ListTile(title: Text('Cargando...')),
                error: (_, _) => const SizedBox.shrink(),
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

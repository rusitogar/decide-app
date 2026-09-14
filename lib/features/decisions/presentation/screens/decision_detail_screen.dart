import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../comments/presentation/widgets/comments_section.dart';
import '../../../social/presentation/widgets/like_button.dart';
import '../../../social/presentation/widgets/save_button.dart';
import '../../../social/presentation/widgets/share_button.dart';
import '../../../users/presentation/providers/user_providers.dart';
import '../../../users/presentation/widgets/user_avatar.dart';
import '../providers/decision_providers.dart';
import '../widgets/voting_section.dart';

class DecisionDetailScreen extends ConsumerWidget {
  const DecisionDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar esta decisión?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed != true) return;

    final failure = await ref.read(editDecisionControllerProvider.notifier).delete(id);
    if (!context.mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisionAsync = ref.watch(decisionProvider(id));
    final optionsAsync = ref.watch(decisionOptionsProvider(id));
    final statsAsync = ref.watch(decisionStatsProvider(id));
    final currentUid = ref.watch(authRepositoryProvider).currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Decisión')),
      body: decisionAsync.when(
        data: (decision) {
          if (decision == null) {
            return const Center(child: Text('Esta decisión no existe (o fue eliminada).'));
          }
          final isOwner = currentUid == decision.authorId;
          final authorAsync = ref.watch(userProfileProvider(decision.authorId));

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  authorAsync.when(
                    data: (author) => author == null
                        ? const SizedBox.shrink()
                        : InkWell(
                            onTap: () => context.push('/profile/${decision.authorId}'),
                            child: Row(
                              children: [
                                UserAvatar(profile: author, radius: 16),
                                const SizedBox(width: 8),
                                Text(author.displayName.isNotEmpty ? author.displayName : '@${author.username}'),
                              ],
                            ),
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  Text(decision.title, style: Theme.of(context).textTheme.headlineSmall),
                  if (decision.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(decision.description),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(decision.category)),
                      if (decision.closesAt != null)
                        Chip(
                          label: Text(decision.isClosed
                              ? 'Cerrada'
                              : 'Cierra el ${decision.closesAt!.day}/${decision.closesAt!.month}/${decision.closesAt!.year}'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  optionsAsync.when(
                    data: (options) => VotingSection(
                      decision: decision,
                      options: options,
                      currentUid: currentUid,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Text('No se pudieron cargar las opciones.'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (currentUid != null) ...[
                        LikeButton(userId: currentUid, decisionId: id),
                        SaveButton(userId: currentUid, decisionId: id),
                      ],
                      ShareButton(decisionId: id, title: decision.title),
                      const Spacer(),
                      statsAsync.when(
                        data: (stats) => Text('${stats.likes} likes'),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  CommentsSection(decisionId: id, currentUid: currentUid),
                  if (isOwner) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => context.push('/decision/$id/edit'),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Editar'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _confirmDelete(context, ref),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

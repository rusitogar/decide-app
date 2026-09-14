import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../decisions/domain/entities/decision.dart';
import '../../../decisions/presentation/providers/decision_providers.dart';
import '../../../users/presentation/providers/user_providers.dart';
import '../../../users/presentation/widgets/user_avatar.dart';

class DecisionCard extends ConsumerWidget {
  const DecisionCard({super.key, required this.decision});

  final Decision decision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorAsync = ref.watch(userProfileProvider(decision.authorId));
    final statsAsync = ref.watch(decisionStatsProvider(decision.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/decision/${decision.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              authorAsync.when(
                data: (author) => author == null
                    ? const SizedBox.shrink()
                    : Row(
                        children: [
                          UserAvatar(profile: author, radius: 12),
                          const SizedBox(width: 8),
                          Text(
                            author.displayName.isNotEmpty ? author.displayName : '@${author.username}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              Text(decision.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(decision.category, style: Theme.of(context).textTheme.bodySmall),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Spacer(),
                  statsAsync.when(
                    data: (stats) => Text('${stats.votes} votos · ${stats.comments} comentarios'),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

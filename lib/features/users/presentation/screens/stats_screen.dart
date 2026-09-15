import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: statsAsync.when(
        data: (stats) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _StatCard(label: 'Decisiones creadas', value: '${stats.decisionsCreated}', icon: Icons.add_chart_outlined),
                    _StatCard(label: 'Votos emitidos', value: '${stats.votesCast}', icon: Icons.how_to_vote_outlined),
                    _StatCard(label: 'Me gusta recibidos', value: '${stats.likesReceived}', icon: Icons.favorite_border),
                    _StatCard(
                        label: 'Comentarios recibidos', value: '${stats.commentsReceived}', icon: Icons.mode_comment_outlined),
                  ],
                ),
                if (stats.topCategory != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.star_outline),
                      title: const Text('Tu categoría favorita'),
                      subtitle: Text(stats.topCategory!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../decisions/presentation/providers/vote_providers.dart';
import '../providers/discover_providers.dart';
import 'discover_card.dart';

/// El contenido del modo Descubrir (swipe vertical, una decisión por
/// pantalla). Vive como una pestaña más del feed, no como pantalla aparte.
///
/// Las decisiones que el usuario ya votó se sacan de la cola: si no, cada
/// vez que se abre la app vuelve a mostrar las mismas de arriba.
class DiscoverFeed extends ConsumerWidget {
  const DiscoverFeed({super.key, required this.currentUid});

  final String? currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(discoverQueueProvider);
    final votedAsync =
        currentUid == null ? const AsyncValue<Set<String>>.data({}) : ref.watch(myVotedDecisionIdsProvider(currentUid!));

    return ColoredBox(
      color: Colors.black,
      child: queueAsync.when(
        data: (queue) {
          final voted = votedAsync.value ?? const {};
          final decisions = queue.where((d) => !voted.contains(d.id)).toList();

          if (decisions.isEmpty) {
            return const Center(
              child: Text(
                'Ya viste todo por ahora.\nVolvé más tarde por más decisiones.',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          }
          return PageView.builder(
            key: ValueKey(decisions.length),
            scrollDirection: Axis.vertical,
            itemCount: decisions.length,
            itemBuilder: (context, index) => DiscoverCard(decision: decisions[index], currentUid: currentUid),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (_, _) => const Center(
          child: Text('No se pudo cargar.', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

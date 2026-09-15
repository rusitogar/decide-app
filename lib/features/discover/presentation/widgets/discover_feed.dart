import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/presentation/providers/feed_providers.dart';
import 'discover_card.dart';

/// El contenido del modo Descubrir (swipe vertical, una decisión por
/// pantalla). Vive como una pestaña más del feed, no como pantalla aparte.
class DiscoverFeed extends ConsumerWidget {
  const DiscoverFeed({super.key, required this.currentUid});

  final String? currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisionsAsync = ref.watch(recentFeedProvider);

    return ColoredBox(
      color: Colors.black,
      child: decisionsAsync.when(
        data: (decisions) {
          if (decisions.isEmpty) {
            return const Center(
              child: Text(
                'Todavía no hay decisiones para descubrir.',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          }
          return PageView.builder(
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

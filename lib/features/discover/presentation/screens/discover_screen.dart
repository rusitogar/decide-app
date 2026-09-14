import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../feed/presentation/providers/feed_providers.dart';
import '../widgets/discover_card.dart';

/// Modo de descubrimiento estilo Reels/TikTok: una decisión por pantalla,
/// deslizando verticalmente para pasar a la siguiente y tocando una opción
/// para votar al toque. Es un modo aparte del feed con categorías (que sigue
/// existiendo tal cual), pensado para navegar rápido y sin pensar mucho.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = ref.watch(authRepositoryProvider).currentUser?.uid;
    final decisionsAsync = ref.watch(recentFeedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          decisionsAsync.when(
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/like_providers.dart';

class LikeButton extends ConsumerWidget {
  const LikeButton({super.key, required this.userId, required this.decisionId});

  final String userId;
  final String decisionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (userId: userId, decisionId: decisionId);
    final likedAsync = ref.watch(isLikedProvider(key));

    return likedAsync.when(
      data: (liked) => IconButton(
        icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : null),
        tooltip: liked ? 'Quitar like' : 'Me gusta',
        onPressed: () => ref
            .read(likeControllerProvider.notifier)
            .toggle(userId: userId, decisionId: decisionId, currentlyLiked: liked),
      ),
      loading: () => const SizedBox(
        height: 40,
        width: 40,
        child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

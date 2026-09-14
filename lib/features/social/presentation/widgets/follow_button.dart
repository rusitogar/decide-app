import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/social_providers.dart';

class FollowButton extends ConsumerWidget {
  const FollowButton({super.key, required this.currentUid, required this.targetUid});

  final String currentUid;
  final String targetUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (followerId: currentUid, followingId: targetUid);
    final isFollowingAsync = ref.watch(isFollowingProvider(args));
    final isSaving = ref.watch(followControllerProvider).isLoading;

    return isFollowingAsync.when(
      data: (isFollowing) => OutlinedButton(
        onPressed: isSaving
            ? null
            : () async {
                final failure = await ref.read(followControllerProvider.notifier).toggle(
                      followerId: currentUid,
                      followingId: targetUid,
                      currentlyFollowing: isFollowing,
                    );
                if (failure != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
                }
              },
        child: Text(isFollowing ? 'Dejar de seguir' : 'Seguir'),
      ),
      loading: () => const SizedBox(
        height: 36,
        width: 36,
        child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

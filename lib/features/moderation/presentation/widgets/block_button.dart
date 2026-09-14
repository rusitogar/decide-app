import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/moderation_providers.dart';

class BlockButton extends ConsumerWidget {
  const BlockButton({super.key, required this.ownerUid, required this.blockedUid});

  final String ownerUid;
  final String blockedUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (ownerUid: ownerUid, blockedUid: blockedUid);
    final blockedAsync = ref.watch(isBlockedProvider(key));

    return blockedAsync.when(
      data: (blocked) => TextButton.icon(
        icon: Icon(blocked ? Icons.block : Icons.block_outlined),
        label: Text(blocked ? 'Desbloquear' : 'Bloquear'),
        onPressed: () => ref
            .read(blockControllerProvider.notifier)
            .toggle(ownerUid: ownerUid, blockedUid: blockedUid, currentlyBlocked: blocked),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/save_providers.dart';

class SaveButton extends ConsumerWidget {
  const SaveButton({super.key, required this.userId, required this.decisionId});

  final String userId;
  final String decisionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (userId: userId, decisionId: decisionId);
    final savedAsync = ref.watch(isSavedProvider(key));

    return savedAsync.when(
      data: (saved) => IconButton(
        icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
        tooltip: saved ? 'Quitar de guardados' : 'Guardar',
        onPressed: () => ref
            .read(saveControllerProvider.notifier)
            .toggle(userId: userId, decisionId: decisionId, currentlySaved: saved),
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

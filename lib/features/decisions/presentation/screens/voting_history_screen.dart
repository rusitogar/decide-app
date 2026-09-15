import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/presentation/widgets/feed_list.dart';
import '../providers/decision_providers.dart';

class VotingHistoryScreen extends ConsumerWidget {
  const VotingHistoryScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(votingHistoryProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de votos')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FeedList(
            decisionsAsync: historyAsync,
            emptyMessage: 'Todavía no votaste ninguna decisión.',
          ),
        ),
      ),
    );
  }
}

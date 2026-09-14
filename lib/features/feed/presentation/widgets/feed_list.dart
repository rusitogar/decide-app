import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../decisions/domain/entities/decision.dart';
import 'decision_card.dart';

class FeedList extends StatelessWidget {
  const FeedList({super.key, required this.decisionsAsync, required this.emptyMessage});

  final AsyncValue<List<Decision>> decisionsAsync;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return decisionsAsync.when(
      data: (decisions) {
        if (decisions.isEmpty) {
          return Center(child: Text(emptyMessage, textAlign: TextAlign.center));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: decisions.length,
          itemBuilder: (context, index) => DecisionCard(decision: decisions[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

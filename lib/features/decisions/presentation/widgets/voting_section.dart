import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/decision.dart';
import '../../domain/entities/decision_option.dart';
import '../providers/vote_providers.dart';

class VotingSection extends ConsumerStatefulWidget {
  const VotingSection({
    super.key,
    required this.decision,
    required this.options,
    required this.currentUid,
  });

  final Decision decision;
  final List<DecisionOption> options;
  final String? currentUid;

  @override
  ConsumerState<VotingSection> createState() => _VotingSectionState();
}

class _VotingSectionState extends ConsumerState<VotingSection> {
  String? _selectedOptionId;

  Future<void> _submitVote() async {
    final uid = widget.currentUid;
    final optionId = _selectedOptionId;
    if (uid == null || optionId == null) return;

    final failure = await ref.read(castVoteControllerProvider.notifier).vote(
          userId: uid,
          decisionId: widget.decision.id,
          optionId: optionId,
        );

    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.currentUid;

    if (uid == null) {
      return _ResultsList(decision: widget.decision, options: widget.options, myOptionId: null);
    }

    final myVoteAsync = ref.watch(myVoteProvider((userId: uid, decisionId: widget.decision.id)));

    return myVoteAsync.when(
      data: (myOptionId) {
        final canVote = myOptionId == null && !widget.decision.isClosed;
        if (!canVote) {
          return _ResultsList(decision: widget.decision, options: widget.options, myOptionId: myOptionId);
        }

        final isVoting = ref.watch(castVoteControllerProvider).isLoading;
        return RadioGroup<String>(
          groupValue: _selectedOptionId,
          onChanged: (v) => setState(() => _selectedOptionId = v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final option in widget.options)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option.text),
                  value: option.id,
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: (_selectedOptionId == null || isVoting) ? null : _submitVote,
                child: isVoting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Votar'),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _ResultsList(decision: widget.decision, options: widget.options, myOptionId: null),
    );
  }
}

class _ResultsList extends ConsumerWidget {
  const _ResultsList({required this.decision, required this.options, required this.myOptionId});

  final Decision decision;
  final List<DecisionOption> options;
  final String? myOptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(voteCountsProvider(decision.id));

    return countsAsync.when(
      data: (counts) {
        final total = counts.values.fold<int>(0, (sum, v) => sum + v);
        final maxVotes = counts.values.isEmpty ? 0 : counts.values.reduce((a, b) => a > b ? a : b);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final option in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ResultBar(
                  option: option,
                  votes: counts[option.id] ?? 0,
                  total: total,
                  isWinner: total > 0 && (counts[option.id] ?? 0) == maxVotes,
                  isMyVote: option.id == myOptionId,
                ),
              ),
            Text('$total votos en total', style: Theme.of(context).textTheme.bodySmall),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Text('No se pudieron cargar los resultados.'),
    );
  }
}

class _ResultBar extends StatelessWidget {
  const _ResultBar({
    required this.option,
    required this.votes,
    required this.total,
    required this.isWinner,
    required this.isMyVote,
  });

  final DecisionOption option;
  final int votes;
  final int total;
  final bool isWinner;
  final bool isMyVote;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : votes / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isWinner) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.emoji_events, size: 16)),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(fontWeight: isWinner ? FontWeight.bold : FontWeight.normal),
              ),
            ),
            if (isMyVote) const Padding(padding: EdgeInsets.only(right: 8), child: Text('Tu voto')),
            Text('${(pct * 100).round()}% ($votes)'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: pct, minHeight: 8),
        ),
      ],
    );
  }
}

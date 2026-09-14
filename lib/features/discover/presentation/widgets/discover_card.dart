import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../comments/presentation/widgets/comments_section.dart';
import '../../../decisions/domain/entities/decision.dart';
import '../../../decisions/domain/entities/decision_option.dart';
import '../../../decisions/presentation/providers/decision_providers.dart';
import '../../../decisions/presentation/providers/vote_providers.dart';
import '../../../social/presentation/providers/like_providers.dart';
import '../../../social/presentation/providers/save_providers.dart';
import '../../../users/presentation/providers/user_providers.dart';

/// Colores lisos para las opciones que todavía no tienen foto propia. Son
/// los mismos tonos apagados usados en las maquetas ("Marca"), elegidos a
/// mano para que se vean bien detrás de las etiquetas blancas.
const _fallbackTileColors = [0xFF233047, 0xFF2A2333, 0xFF1F3327, 0xFF3A2A1F, 0xFF2A2020];

Color _fallbackColorFor(String id) => Color(_fallbackTileColors[id.hashCode.abs() % _fallbackTileColors.length]);

const _brandBlue = Color(0xFF2F6FEB);

class DiscoverCard extends ConsumerWidget {
  const DiscoverCard({super.key, required this.decision, required this.currentUid});

  final Decision decision;
  final String? currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(decisionOptionsProvider(decision.id));

    return optionsAsync.when(
      data: (options) {
        if (options.isEmpty) return const SizedBox.shrink();
        return _DiscoverCardBody(decision: decision, options: options, currentUid: currentUid);
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _DiscoverCardBody extends ConsumerWidget {
  const _DiscoverCardBody({required this.decision, required this.options, required this.currentUid});

  final Decision decision;
  final List<DecisionOption> options;
  final String? currentUid;

  Future<void> _vote(WidgetRef ref, String optionId) async {
    final uid = currentUid;
    if (uid == null) return;
    await ref.read(castVoteControllerProvider.notifier).vote(
          userId: uid,
          decisionId: decision.id,
          optionId: optionId,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorAsync = ref.watch(userProfileProvider(decision.authorId));
    final myVoteAsync = currentUid == null
        ? const AsyncValue<String?>.data(null)
        : ref.watch(myVoteProvider((userId: currentUid!, decisionId: decision.id)));
    final myOptionId = myVoteAsync.value;
    final hasVoted = myOptionId != null;

    final countsAsync = hasVoted ? ref.watch(voteCountsProvider(decision.id)) : const AsyncValue<Map<String, int>>.data({});
    final counts = countsAsync.value ?? const {};
    final total = counts.values.fold<int>(0, (sum, v) => sum + v);

    return Stack(
      fit: StackFit.expand,
      children: [
        _OptionsLayout(
          options: options,
          hasVoted: hasVoted,
          myOptionId: myOptionId,
          counts: counts,
          total: total,
          onTap: hasVoted ? null : (optionId) => _vote(ref, optionId),
        ),

        Positioned(
          top: 12,
          left: 16,
          right: 64,
          child: Row(
            children: [
              authorAsync.when(
                data: (author) => CircleAvatar(
                  radius: 10,
                  backgroundColor: author != null ? Color(author.avatarColor) : Colors.white24,
                  backgroundImage:
                      author != null && author.avatarUrl.isNotEmpty ? NetworkImage(author.avatarUrl) : null,
                ),
                loading: () => const CircleAvatar(radius: 10, backgroundColor: Colors.white24),
                error: (_, _) => const CircleAvatar(radius: 10, backgroundColor: Colors.white24),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  authorAsync.value?.displayName.isNotEmpty == true
                      ? authorAsync.value!.displayName
                      : '@${authorAsync.value?.username ?? ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: 34,
          left: 16,
          right: 64,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(8)),
            child: Text(
              decision.title,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, height: 1.3),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        Positioned(
          right: 10,
          bottom: 110,
          child: _IconRail(decisionId: decision.id, currentUid: currentUid, title: decision.title),
        ),
      ],
    );
  }
}

class _OptionsLayout extends StatelessWidget {
  const _OptionsLayout({
    required this.options,
    required this.hasVoted,
    required this.myOptionId,
    required this.counts,
    required this.total,
    required this.onTap,
  });

  final List<DecisionOption> options;
  final bool hasVoted;
  final String? myOptionId;
  final Map<String, int> counts;
  final int total;
  final void Function(String optionId)? onTap;

  @override
  Widget build(BuildContext context) {
    if (options.length == 2) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Row(
            children: [
              for (final option in options)
                Expanded(
                  child: _OptionTile(
                    option: option,
                    hasVoted: hasVoted,
                    isMine: option.id == myOptionId,
                    votes: counts[option.id] ?? 0,
                    total: total,
                    onTap: onTap == null ? null : () => onTap!(option.id),
                  ),
                ),
            ],
          ),
          if (!hasVoted)
            Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('VS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
              ),
            ),
        ],
      );
    }

    final rows = <List<DecisionOption>>[];
    for (var i = 0; i < options.length; i += 2) {
      rows.add(options.sublist(i, (i + 2).clamp(0, options.length)));
    }

    return Column(
      children: [
        for (final row in rows)
          Expanded(
            child: Row(
              children: [
                for (final option in row)
                  Expanded(
                    child: _OptionTile(
                      option: option,
                      hasVoted: hasVoted,
                      isMine: option.id == myOptionId,
                      votes: counts[option.id] ?? 0,
                      total: total,
                      onTap: onTap == null ? null : () => onTap!(option.id),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.hasVoted,
    required this.isMine,
    required this.votes,
    required this.total,
    required this.onTap,
  });

  final DecisionOption option;
  final bool hasVoted;
  final bool isMine;
  final int votes;
  final int total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : votes / total;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _fallbackColorFor(option.id),
          image: option.imageUrl.isNotEmpty
              ? DecorationImage(image: NetworkImage(option.imageUrl), fit: BoxFit.cover)
              : null,
          border: isMine ? Border.all(color: _brandBlue, width: 2) : null,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: hasVoted
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.text,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(_brandBlue),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(pct * 100).round()}% · $votes',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _brandBlue, borderRadius: BorderRadius.circular(7)),
                    child: Text(
                      option.text,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _IconRail extends ConsumerWidget {
  const _IconRail({required this.decisionId, required this.currentUid, required this.title});

  final String decisionId;
  final String? currentUid;
  final String title;

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: '$title\n\nhttps://decide.app/decision/$decisionId',
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      ),
    );
    await FirebaseAnalytics.instance.logShare(contentType: 'decision', itemId: decisionId, method: 'share_sheet');
  }

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.75,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: CommentsSection(decisionId: decisionId, currentUid: currentUid),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = currentUid;
    final statsAsync = ref.watch(decisionStatsProvider(decisionId));
    final likedAsync =
        uid == null ? const AsyncValue<bool>.data(false) : ref.watch(isLikedProvider((userId: uid, decisionId: decisionId)));
    final savedAsync =
        uid == null ? const AsyncValue<bool>.data(false) : ref.watch(isSavedProvider((userId: uid, decisionId: decisionId)));
    final liked = likedAsync.value ?? false;
    final saved = savedAsync.value ?? false;

    return Column(
      children: [
        _RailButton(
          icon: liked ? Icons.favorite : Icons.favorite_border,
          color: liked ? Colors.red : Colors.white,
          label: '${statsAsync.value?.likes ?? 0}',
          onTap: uid == null
              ? null
              : () => ref
                  .read(likeControllerProvider.notifier)
                  .toggle(userId: uid, decisionId: decisionId, currentlyLiked: liked),
        ),
        const SizedBox(height: 18),
        _RailButton(
          icon: Icons.mode_comment_outlined,
          color: Colors.white,
          label: '${statsAsync.value?.comments ?? 0}',
          onTap: () => _openComments(context),
        ),
        const SizedBox(height: 18),
        _RailButton(icon: Icons.share_outlined, color: Colors.white, onTap: () => _share(context)),
        const SizedBox(height: 18),
        _RailButton(
          icon: saved ? Icons.bookmark : Icons.bookmark_border,
          color: Colors.white,
          onTap: uid == null
              ? null
              : () => ref
                  .read(saveControllerProvider.notifier)
                  .toggle(userId: uid, decisionId: decisionId, currentlySaved: saved),
        ),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.icon, required this.color, this.label, this.onTap});

  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 25),
          if (label != null) ...[
            const SizedBox(height: 2),
            Text(label!, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

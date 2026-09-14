import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../moderation/domain/repositories/moderation_repository.dart';
import '../../../moderation/presentation/widgets/report_dialog.dart';
import '../../../users/presentation/providers/user_providers.dart';
import '../../../users/presentation/widgets/user_avatar.dart';
import '../../domain/entities/comment.dart';
import '../providers/comment_providers.dart';

class CommentsSection extends ConsumerStatefulWidget {
  const CommentsSection({super.key, required this.decisionId, required this.currentUid});

  final String decisionId;
  final String? currentUid;

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final uid = widget.currentUid;
    if (uid == null || _controller.text.trim().isEmpty) return;

    final failure = await ref
        .read(commentControllerProvider.notifier)
        .create(decisionId: widget.decisionId, authorId: uid, text: _controller.text);

    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    } else {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.decisionId));
    final isSending = ref.watch(commentControllerProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comentarios', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (widget.currentUid != null)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Escribí un comentario...'),
                  onSubmitted: (_) => _send(),
                ),
              ),
              IconButton(
                icon: isSending
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                onPressed: isSending ? null : _send,
              ),
            ],
          ),
        const SizedBox(height: 8),
        commentsAsync.when(
          data: (comments) {
            if (comments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Todavía no hay comentarios.'),
              );
            }
            return Column(
              children: comments.map((c) => _CommentTile(comment: c, currentUid: widget.currentUid)).toList(),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const Text('No se pudieron cargar los comentarios.'),
        ),
      ],
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({required this.comment, required this.currentUid});

  final Comment comment;
  final String? currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorAsync = ref.watch(userProfileProvider(comment.authorId));
    final isMine = currentUid == comment.authorId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          authorAsync.when(
            data: (author) => author == null ? const SizedBox(width: 32) : UserAvatar(profile: author, radius: 16),
            loading: () => const SizedBox(width: 32),
            error: (_, _) => const SizedBox(width: 32),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                authorAsync.when(
                  data: (author) => Text(
                    author == null ? '' : (author.displayName.isNotEmpty ? author.displayName : '@${author.username}'),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                Text(comment.text),
              ],
            ),
          ),
          if (isMine)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => ref.read(commentControllerProvider.notifier).delete(comment.id),
            )
          else if (currentUid != null)
            IconButton(
              icon: const Icon(Icons.flag_outlined, size: 18),
              tooltip: 'Reportar',
              onPressed: () => showReportDialog(
                context,
                ref,
                reporterId: currentUid!,
                targetType: ReportTargetType.comment,
                targetId: comment.id,
              ),
            ),
        ],
      ),
    );
  }
}

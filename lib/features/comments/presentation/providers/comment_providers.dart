import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) => CommentRepositoryImpl());

final commentsProvider = StreamProvider.autoDispose.family<List<Comment>, String>(
  (ref, decisionId) => ref.watch(commentRepositoryProvider).watchComments(decisionId),
);

class CommentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> create({required String decisionId, required String authorId, required String text}) async {
    state = const AsyncLoading();
    final result =
        await ref.read(commentRepositoryProvider).createComment(decisionId: decisionId, authorId: authorId, text: text);
    state = const AsyncData(null);
    return result.when(success: (_) => null, failure: (f) => f);
  }

  Future<void> delete(String commentId) async {
    await ref.read(commentRepositoryProvider).deleteComment(commentId);
  }
}

final commentControllerProvider = AsyncNotifierProvider<CommentController, void>(CommentController.new);

import '../../../../core/error/result.dart';
import '../entities/comment.dart';

abstract interface class CommentRepository {
  Stream<List<Comment>> watchComments(String decisionId);

  Future<Result<void>> createComment({
    required String decisionId,
    required String authorId,
    required String text,
  });

  Future<Result<void>> deleteComment(String commentId);
}

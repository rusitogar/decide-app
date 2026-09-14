import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Comment _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Comment(
      id: doc.id,
      decisionId: data['decisionId'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Stream<List<Comment>> watchComments(String decisionId) {
    return _firestore
        .collection('comments')
        .where('decisionId', isEqualTo: decisionId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Future<Result<void>> createComment({
    required String decisionId,
    required String authorId,
    required String text,
  }) async {
    if (text.trim().isEmpty) {
      return const Result.failure(ValidationFailure('Escribí algo para comentar.'));
    }
    try {
      await _firestore.collection('comments').add({
        'decisionId': decisionId,
        'authorId': authorId,
        'text': text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('createComment failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    try {
      await _firestore.collection('comments').doc(commentId).delete();
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('deleteComment failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }
}

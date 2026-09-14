import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/repositories/like_repository.dart';

class LikeRepositoryImpl implements LikeRepository {
  LikeRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String _id(String userId, String decisionId) => '${userId}_$decisionId';

  @override
  Future<Result<bool>> isLiked({required String userId, required String decisionId}) async {
    try {
      final doc = await _firestore.collection('likes').doc(_id(userId, decisionId)).get();
      return Result.success(doc.exists);
    } catch (e, st) {
      appLogger.e('isLiked failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> like({required String userId, required String decisionId}) async {
    try {
      await _firestore.collection('likes').doc(_id(userId, decisionId)).set({
        'userId': userId,
        'decisionId': decisionId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('like failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> unlike({required String userId, required String decisionId}) async {
    try {
      await _firestore.collection('likes').doc(_id(userId, decisionId)).delete();
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('unlike failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }
}

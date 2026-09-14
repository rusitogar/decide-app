import '../../../../core/error/result.dart';

abstract interface class LikeRepository {
  Future<Result<bool>> isLiked({required String userId, required String decisionId});

  Future<Result<void>> like({required String userId, required String decisionId});

  Future<Result<void>> unlike({required String userId, required String decisionId});
}

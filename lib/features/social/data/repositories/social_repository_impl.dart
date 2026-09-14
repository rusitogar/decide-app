import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/repositories/social_repository.dart';

class SocialRepositoryImpl implements SocialRepository {
  SocialRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String _followId(String followerId, String followingId) => '${followerId}_$followingId';

  @override
  Future<Result<bool>> isFollowing({required String followerId, required String followingId}) async {
    try {
      final doc = await _firestore
          .collection('follows')
          .doc(_followId(followerId, followingId))
          .get();
      return Result.success(doc.exists);
    } catch (e, st) {
      appLogger.e('isFollowing failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> follow({required String followerId, required String followingId}) async {
    if (followerId == followingId) {
      return const Result.failure(ValidationFailure('No podés seguirte a vos mismo.'));
    }
    try {
      await _firestore.collection('follows').doc(_followId(followerId, followingId)).set({
        'followerId': followerId,
        'followingId': followingId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('follow failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> unfollow({required String followerId, required String followingId}) async {
    try {
      await _firestore.collection('follows').doc(_followId(followerId, followingId)).delete();
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('unfollow failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }
}

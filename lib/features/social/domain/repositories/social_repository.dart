import '../../../../core/error/result.dart';

abstract interface class SocialRepository {
  Future<Result<bool>> isFollowing({required String followerId, required String followingId});

  Future<Result<void>> follow({required String followerId, required String followingId});

  Future<Result<void>> unfollow({required String followerId, required String followingId});
}

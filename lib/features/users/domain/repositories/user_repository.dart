import '../../../../core/error/result.dart';
import '../entities/profile_counts.dart';
import '../entities/user_profile.dart';

abstract interface class UserRepository {
  Stream<UserProfile?> watchProfile(String uid);

  Future<Result<ProfileCounts>> getProfileCounts(String uid);

  /// true si `username` está libre (o es el que ya tiene `currentUid`).
  Future<Result<bool>> isUsernameAvailable(String username, {required String currentUid});

  Future<Result<void>> updateProfile({
    required String uid,
    required String username,
    required String displayName,
    required String bio,
    required int avatarColor,
  });
}

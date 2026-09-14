import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/profile_counts.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepositoryImpl());

final userProfileProvider = StreamProvider.autoDispose.family<UserProfile?, String>(
  (ref, uid) => ref.watch(userRepositoryProvider).watchProfile(uid),
);

final profileCountsProvider = FutureProvider.autoDispose.family<ProfileCounts, String>(
  (ref, uid) async {
    final result = await ref.watch(userRepositoryProvider).getProfileCounts(uid);
    return result.when(
      success: (value) => value,
      failure: (_) => const ProfileCounts(followers: 0, following: 0, decisions: 0),
    );
  },
);

class EditProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> save({
    required String uid,
    required String username,
    required String displayName,
    required String bio,
    required int avatarColor,
    String? avatarUrl,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(userRepositoryProvider).updateProfile(
          uid: uid,
          username: username,
          displayName: displayName,
          bio: bio,
          avatarColor: avatarColor,
          avatarUrl: avatarUrl,
        );
    state = const AsyncData(null);
    return result.when(success: (_) => null, failure: (f) => f);
  }
}

final editProfileControllerProvider =
    AsyncNotifierProvider<EditProfileController, void>(EditProfileController.new);

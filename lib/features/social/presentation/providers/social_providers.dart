import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../users/presentation/providers/user_providers.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../domain/repositories/social_repository.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) => SocialRepositoryImpl());

final isFollowingProvider = FutureProvider.autoDispose.family<bool, ({String followerId, String followingId})>(
  (ref, args) async {
    final result = await ref
        .watch(socialRepositoryProvider)
        .isFollowing(followerId: args.followerId, followingId: args.followingId);
    return result.when(success: (value) => value, failure: (_) => false);
  },
);

class FollowController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> toggle({
    required String followerId,
    required String followingId,
    required bool currentlyFollowing,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(socialRepositoryProvider);
    final result = currentlyFollowing
        ? await repo.unfollow(followerId: followerId, followingId: followingId)
        : await repo.follow(followerId: followerId, followingId: followingId);
    state = const AsyncData(null);

    result.when(
      success: (_) {
        ref.invalidate(isFollowingProvider((followerId: followerId, followingId: followingId)));
        ref.invalidate(profileCountsProvider(followingId));
        ref.invalidate(profileCountsProvider(followerId));
      },
      failure: (_) {},
    );
    return result.when(success: (_) => null, failure: (f) => f);
  }
}

final followControllerProvider = AsyncNotifierProvider<FollowController, void>(FollowController.new);

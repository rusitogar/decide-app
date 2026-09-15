import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../decisions/domain/entities/decision.dart';
import '../../../decisions/presentation/providers/decision_providers.dart';
import '../../../decisions/presentation/providers/vote_providers.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/profile_counts.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_stats.dart';
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

final userStatsProvider = FutureProvider.autoDispose.family<UserStats, String>((ref, uid) async {
  final decisionRepo = ref.watch(decisionRepositoryProvider);
  final voteRepo = ref.watch(voteRepositoryProvider);

  final ownResult = await decisionRepo.listByAuthor(uid);
  final ownDecisions = ownResult.when(success: (v) => v, failure: (_) => const <Decision>[]);

  final statsResults = await Future.wait(ownDecisions.map((d) => decisionRepo.getDecisionStats(d.id)));
  var likes = 0;
  var comments = 0;
  for (final r in statsResults) {
    r.when(
      success: (s) {
        likes += s.likes;
        comments += s.comments;
      },
      failure: (_) {},
    );
  }

  final votedResult = await voteRepo.getMyVotedDecisionIds(uid);
  final votedIds = votedResult.when(success: (v) => v, failure: (_) => const <String>{});

  String? topCategory;
  if (votedIds.isNotEmpty) {
    final votedResult = await decisionRepo.getByIds(votedIds.toList());
    final votedDecisions = votedResult.when(success: (v) => v, failure: (_) => const <Decision>[]);
    final counts = <String, int>{};
    for (final d in votedDecisions) {
      if (d.category.isEmpty) continue;
      counts[d.category] = (counts[d.category] ?? 0) + 1;
    }
    if (counts.isNotEmpty) {
      topCategory = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }
  }

  return UserStats(
    decisionsCreated: ownDecisions.length,
    votesCast: votedIds.length,
    likesReceived: likes,
    commentsReceived: comments,
    topCategory: topCategory,
  );
});

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

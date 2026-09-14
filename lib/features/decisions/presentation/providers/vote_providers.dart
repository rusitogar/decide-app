import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/vote_repository_impl.dart';
import '../../domain/repositories/vote_repository.dart';
import 'decision_providers.dart';

final voteRepositoryProvider = Provider<VoteRepository>((ref) => VoteRepositoryImpl());

typedef _VoteKey = ({String userId, String decisionId});

final myVoteProvider = FutureProvider.autoDispose.family<String?, _VoteKey>((ref, key) async {
  final result = await ref.watch(voteRepositoryProvider).getMyVote(
        userId: key.userId,
        decisionId: key.decisionId,
      );
  return result.when(success: (v) => v, failure: (_) => null);
});

final voteCountsProvider = FutureProvider.autoDispose.family<Map<String, int>, String>((ref, decisionId) async {
  final result = await ref.watch(voteRepositoryProvider).getVoteCountsByOption(decisionId);
  return result.when(success: (v) => v, failure: (_) => const {});
});

class CastVoteController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> vote({
    required String userId,
    required String decisionId,
    required String optionId,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(voteRepositoryProvider).castVote(
          userId: userId,
          decisionId: decisionId,
          optionId: optionId,
        );
    state = const AsyncData(null);

    result.when(
      success: (_) {
        ref.invalidate(myVoteProvider((userId: userId, decisionId: decisionId)));
        ref.invalidate(voteCountsProvider(decisionId));
        ref.invalidate(decisionStatsProvider(decisionId));
      },
      failure: (_) {},
    );
    return result.when(success: (_) => null, failure: (f) => f);
  }
}

final castVoteControllerProvider = AsyncNotifierProvider<CastVoteController, void>(CastVoteController.new);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../decisions/presentation/providers/decision_providers.dart';
import '../../data/repositories/like_repository_impl.dart';
import '../../domain/repositories/like_repository.dart';

final likeRepositoryProvider = Provider<LikeRepository>((ref) => LikeRepositoryImpl());

final isLikedProvider = FutureProvider.autoDispose.family<bool, ({String userId, String decisionId})>(
  (ref, key) async {
    final result = await ref.watch(likeRepositoryProvider).isLiked(userId: key.userId, decisionId: key.decisionId);
    return result.when(success: (v) => v, failure: (_) => false);
  },
);

class LikeController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggle({required String userId, required String decisionId, required bool currentlyLiked}) async {
    final repo = ref.read(likeRepositoryProvider);
    final result = currentlyLiked
        ? await repo.unlike(userId: userId, decisionId: decisionId)
        : await repo.like(userId: userId, decisionId: decisionId);

    result.when(
      success: (_) {
        ref.invalidate(isLikedProvider((userId: userId, decisionId: decisionId)));
        ref.invalidate(decisionStatsProvider(decisionId));
      },
      failure: (_) {},
    );
  }
}

final likeControllerProvider = AsyncNotifierProvider<LikeController, void>(LikeController.new);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/moderation_repository_impl.dart';
import '../../domain/repositories/moderation_repository.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) => ModerationRepositoryImpl());

final isBlockedProvider = FutureProvider.autoDispose.family<bool, ({String ownerUid, String blockedUid})>(
  (ref, key) async {
    final result =
        await ref.watch(moderationRepositoryProvider).isBlocked(ownerUid: key.ownerUid, blockedUid: key.blockedUid);
    return result.when(success: (v) => v, failure: (_) => false);
  },
);

final blockedUserIdsProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, ownerUid) async {
  final result = await ref.watch(moderationRepositoryProvider).listBlockedUserIds(ownerUid);
  return result.when(success: (v) => v, failure: (_) => const []);
});

class ReportController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> submit({
    required String reporterId,
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(moderationRepositoryProvider)
        .createReport(reporterId: reporterId, targetType: targetType, targetId: targetId, reason: reason);
    state = const AsyncData(null);
    return result.when(success: (_) => null, failure: (f) => f);
  }
}

final reportControllerProvider = AsyncNotifierProvider<ReportController, void>(ReportController.new);

class BlockController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggle({required String ownerUid, required String blockedUid, required bool currentlyBlocked}) async {
    final repo = ref.read(moderationRepositoryProvider);
    final result = currentlyBlocked
        ? await repo.unblockUser(ownerUid: ownerUid, blockedUid: blockedUid)
        : await repo.blockUser(ownerUid: ownerUid, blockedUid: blockedUid);

    result.when(
      success: (_) {
        ref.invalidate(isBlockedProvider((ownerUid: ownerUid, blockedUid: blockedUid)));
        ref.invalidate(blockedUserIdsProvider(ownerUid));
      },
      failure: (_) {},
    );
  }
}

final blockControllerProvider = AsyncNotifierProvider<BlockController, void>(BlockController.new);

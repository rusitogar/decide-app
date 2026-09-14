import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/save_repository_impl.dart';
import '../../domain/repositories/save_repository.dart';

final saveRepositoryProvider = Provider<SaveRepository>((ref) => SaveRepositoryImpl());

final isSavedProvider = FutureProvider.autoDispose.family<bool, ({String userId, String decisionId})>(
  (ref, key) async {
    final result = await ref.watch(saveRepositoryProvider).isSaved(userId: key.userId, decisionId: key.decisionId);
    return result.when(success: (v) => v, failure: (_) => false);
  },
);

final savedDecisionIdsProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, userId) async {
  final result = await ref.watch(saveRepositoryProvider).listSavedDecisionIds(userId);
  return result.when(success: (v) => v, failure: (_) => const []);
});

class SaveController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggle({required String userId, required String decisionId, required bool currentlySaved}) async {
    final repo = ref.read(saveRepositoryProvider);
    final result = currentlySaved
        ? await repo.unsave(userId: userId, decisionId: decisionId)
        : await repo.save(userId: userId, decisionId: decisionId);

    result.when(
      success: (_) {
        ref.invalidate(isSavedProvider((userId: userId, decisionId: decisionId)));
        ref.invalidate(savedDecisionIdsProvider(userId));
      },
      failure: (_) {},
    );
  }
}

final saveControllerProvider = AsyncNotifierProvider<SaveController, void>(SaveController.new);

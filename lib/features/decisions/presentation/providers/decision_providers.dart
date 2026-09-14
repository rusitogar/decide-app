import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/decision_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/decision.dart';
import '../../domain/entities/decision_option.dart';
import '../../domain/entities/decision_stats.dart';
import '../../domain/repositories/decision_repository.dart';

final decisionRepositoryProvider = Provider<DecisionRepository>((ref) => DecisionRepositoryImpl());

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final result = await ref.watch(decisionRepositoryProvider).getCategories();
  return result.when(success: (v) => v, failure: (_) => const []);
});

final decisionProvider = StreamProvider.autoDispose.family<Decision?, String>(
  (ref, id) => ref.watch(decisionRepositoryProvider).watchDecision(id),
);

final decisionOptionsProvider = StreamProvider.autoDispose.family<List<DecisionOption>, String>(
  (ref, id) => ref.watch(decisionRepositoryProvider).watchOptions(id),
);

final decisionStatsProvider = FutureProvider.autoDispose.family<DecisionStats, String>((ref, id) async {
  final result = await ref.watch(decisionRepositoryProvider).getDecisionStats(id);
  return result.when(success: (v) => v, failure: (_) => const DecisionStats(votes: 0, comments: 0, likes: 0));
});

final decisionsByAuthorProvider = FutureProvider.autoDispose.family<List<Decision>, String>((ref, authorId) async {
  final result = await ref.watch(decisionRepositoryProvider).listByAuthor(authorId);
  return result.when(success: (v) => v, failure: (_) => const []);
});

class CreateDecisionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<({String? id, Failure? failure})> create({
    required String authorId,
    required String title,
    required String description,
    required String category,
    required List<({String text, String link})> options,
    DateTime? closesAt,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(decisionRepositoryProvider).createDecision(
          authorId: authorId,
          title: title,
          description: description,
          category: category,
          options: options,
          closesAt: closesAt,
        );
    state = const AsyncData(null);
    return result.when(
      success: (id) => (id: id, failure: null),
      failure: (f) => (id: null, failure: f),
    );
  }
}

final createDecisionControllerProvider =
    AsyncNotifierProvider<CreateDecisionController, void>(CreateDecisionController.new);

class EditDecisionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> save({
    required String id,
    required String title,
    required String description,
    required String category,
    DateTime? closesAt,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(decisionRepositoryProvider).updateDecision(
          id: id,
          title: title,
          description: description,
          category: category,
          closesAt: closesAt,
        );
    state = const AsyncData(null);
    return result.when(success: (_) => null, failure: (f) => f);
  }

  Future<Failure?> delete(String id) async {
    state = const AsyncLoading();
    final result = await ref.read(decisionRepositoryProvider).deleteDecision(id);
    state = const AsyncData(null);
    return result.when(success: (_) => null, failure: (f) => f);
  }
}

final editDecisionControllerProvider =
    AsyncNotifierProvider<EditDecisionController, void>(EditDecisionController.new);

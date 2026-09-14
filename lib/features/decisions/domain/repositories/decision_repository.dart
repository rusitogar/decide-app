import '../../../../core/error/result.dart';
import '../entities/category.dart';
import '../entities/decision.dart';
import '../entities/decision_option.dart';
import '../entities/decision_stats.dart';

abstract interface class DecisionRepository {
  Future<Result<List<Category>>> getCategories();

  Future<Result<String>> createDecision({
    required String authorId,
    required String title,
    required String description,
    required String category,
    required List<String> optionTexts,
    DateTime? closesAt,
  });

  Stream<Decision?> watchDecision(String id);

  Stream<List<DecisionOption>> watchOptions(String decisionId);

  Future<Result<DecisionStats>> getDecisionStats(String decisionId);

  Future<Result<List<Decision>>> listByAuthor(String authorId);

  Future<Result<void>> updateDecision({
    required String id,
    required String title,
    required String description,
    required String category,
    DateTime? closesAt,
  });

  Future<Result<void>> deleteDecision(String id);
}

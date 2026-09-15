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
    required List<({String text, String link, String imageUrl})> options,
    DateTime? closesAt,
  });

  Stream<Decision?> watchDecision(String id);

  Stream<List<DecisionOption>> watchOptions(String decisionId);

  Future<Result<DecisionStats>> getDecisionStats(String decisionId);

  Future<Result<List<Decision>>> listByAuthor(String authorId);

  /// Trae varias decisiones por id (usado para el historial de votos: no
  /// hay una colección "voté esto", solo los ids en `votes`).
  Future<Result<List<Decision>>> getByIds(List<String> ids);

  /// El dueño cierra la votación ya mismo, tenga o no fecha de cierre
  /// puesta. Reutiliza `closesAt`: lo deja en el momento actual.
  Future<Result<void>> closeDecisionNow(String id);

  Future<Result<void>> updateDecision({
    required String id,
    required String title,
    required String description,
    required String category,
    DateTime? closesAt,
  });

  Future<Result<void>> deleteDecision(String id);
}

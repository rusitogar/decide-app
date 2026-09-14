import '../../../../core/error/result.dart';

abstract interface class SaveRepository {
  Future<Result<bool>> isSaved({required String userId, required String decisionId});

  Future<Result<void>> save({required String userId, required String decisionId});

  Future<Result<void>> unsave({required String userId, required String decisionId});

  /// Ids de las decisiones guardadas por el usuario, más recientes primero.
  Future<Result<List<String>>> listSavedDecisionIds(String userId);
}

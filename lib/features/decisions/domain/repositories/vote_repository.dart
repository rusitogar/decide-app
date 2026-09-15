import '../../../../core/error/result.dart';

abstract interface class VoteRepository {
  /// Devuelve el id de la opción que votó el usuario, o null si no votó.
  Future<Result<String?>> getMyVote({required String userId, required String decisionId});

  Future<Result<void>> castVote({
    required String userId,
    required String decisionId,
    required String optionId,
  });

  /// Cantidad de votos por opción: { optionId: cantidad }.
  Future<Result<Map<String, int>>> getVoteCountsByOption(String decisionId);

  /// Ids de las decisiones en las que ya votó el usuario. Se usa para no
  /// volver a mostrárselas en el modo Descubrir. Es una foto del momento
  /// (no reactivo): así, si acabás de votar, la tarjeta actual se queda
  /// mostrando el resultado en vez de desaparecer de golpe de la cola.
  Future<Result<Set<String>>> getMyVotedDecisionIds(String userId);
}

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
}

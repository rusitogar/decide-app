import '../../../../core/error/result.dart';
import '../../../decisions/domain/entities/decision.dart';

abstract interface class FeedRepository {
  /// Orden cronológico. Usado también como "Para vos" inicial (ver doc: sin
  /// algoritmo de recomendación todavía).
  Future<Result<List<Decision>>> getRecent({int limit});

  /// Aproximación simple de "Tendencias": toma un lote de las decisiones más
  /// recientes y las ordena por actividad (votos+likes+comentarios). No
  /// escala a un catálogo enorme (no hay contadores denormalizados hasta
  /// tener Cloud Functions con Blaze), pero alcanza para el volumen de la
  /// beta privada.
  Future<Result<List<Decision>>> getTrending({int poolSize, int limit});

  Future<Result<List<Decision>>> getFollowing({required String userId, int limit});

  Future<Result<List<Decision>>> getByCategory({required String category, int limit});
}

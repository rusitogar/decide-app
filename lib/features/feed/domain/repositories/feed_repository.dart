import '../../../../core/error/result.dart';
import '../../../decisions/domain/entities/decision.dart';

abstract interface class FeedRepository {
  /// Orden cronológico. Usado también como "Para vos" inicial (ver doc: sin
  /// algoritmo de recomendación todavía). Es un stream (en vez de un fetch
  /// único) para que la lista se actualice sola cuando se crea una decisión
  /// nueva, sin depender de que el usuario navegue para refrescar.
  Stream<List<Decision>> watchRecent({int limit});

  /// Aproximación simple de "Tendencias": toma un lote de las decisiones más
  /// recientes y las ordena por actividad (votos+likes+comentarios). No
  /// escala a un catálogo enorme (no hay contadores denormalizados en el
  /// documento de la decisión todavía), pero alcanza para el volumen de la
  /// beta privada.
  Future<Result<List<Decision>>> getTrending({int poolSize, int limit});

  Stream<List<Decision>> watchFollowing({required String userId, int limit});

  Stream<List<Decision>> watchByCategory({required String category, int limit});
}

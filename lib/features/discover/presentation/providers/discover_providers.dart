import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../decisions/domain/entities/decision.dart';
import '../../../feed/presentation/providers/feed_providers.dart';

/// Pool más grande que el de "Para vos" (que se queda en 20): acá hace
/// falta más margen porque después se filtran las que el usuario ya votó.
final discoverQueueProvider = StreamProvider.autoDispose<List<Decision>>((ref) {
  return ref.watch(feedRepositoryProvider).watchRecent(limit: 60);
});

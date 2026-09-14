import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../decisions/domain/entities/decision.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/repositories/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) => FeedRepositoryImpl());

final recentFeedProvider = StreamProvider.autoDispose<List<Decision>>((ref) {
  return ref.watch(feedRepositoryProvider).watchRecent(limit: 20);
});

final trendingFeedProvider = FutureProvider.autoDispose<List<Decision>>((ref) async {
  final result = await ref.watch(feedRepositoryProvider).getTrending(poolSize: 20, limit: 10);
  return result.when(success: (v) => v, failure: (_) => const []);
});

final followingFeedProvider = StreamProvider.autoDispose.family<List<Decision>, String>((ref, userId) {
  return ref.watch(feedRepositoryProvider).watchFollowing(userId: userId, limit: 20);
});

final categoryFeedProvider = StreamProvider.autoDispose.family<List<Decision>, String>((ref, category) {
  return ref.watch(feedRepositoryProvider).watchByCategory(category: category, limit: 20);
});

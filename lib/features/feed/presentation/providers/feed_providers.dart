import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../decisions/domain/entities/decision.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/repositories/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) => FeedRepositoryImpl());

final recentFeedProvider = FutureProvider.autoDispose<List<Decision>>((ref) async {
  final result = await ref.watch(feedRepositoryProvider).getRecent(limit: 20);
  return result.when(success: (v) => v, failure: (_) => const []);
});

final trendingFeedProvider = FutureProvider.autoDispose<List<Decision>>((ref) async {
  final result = await ref.watch(feedRepositoryProvider).getTrending(poolSize: 20, limit: 10);
  return result.when(success: (v) => v, failure: (_) => const []);
});

final followingFeedProvider = FutureProvider.autoDispose.family<List<Decision>, String>((ref, userId) async {
  final result = await ref.watch(feedRepositoryProvider).getFollowing(userId: userId, limit: 20);
  return result.when(success: (v) => v, failure: (_) => const []);
});

final categoryFeedProvider = FutureProvider.autoDispose.family<List<Decision>, String>((ref, category) async {
  final result = await ref.watch(feedRepositoryProvider).getByCategory(category: category, limit: 20);
  return result.when(success: (v) => v, failure: (_) => const []);
});

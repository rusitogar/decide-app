import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../decisions/domain/entities/decision.dart';
import '../../domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Decision _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Decision(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      closesAt: (data['closesAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Stream<List<Decision>> watchRecent({int limit = 20}) {
    return _firestore
        .collection('decisions')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Future<Result<List<Decision>>> getTrending({int poolSize = 20, int limit = 10}) async {
    try {
      final snap = await _firestore
          .collection('decisions')
          .orderBy('createdAt', descending: true)
          .limit(poolSize)
          .get();
      final decisions = snap.docs.map(_fromDoc).toList();

      final scores = await Future.wait(decisions.map((d) async {
        final results = await Future.wait([
          _firestore.collection('votes').where('decisionId', isEqualTo: d.id).count().get(),
          _firestore.collection('likes').where('decisionId', isEqualTo: d.id).count().get(),
          _firestore.collection('comments').where('decisionId', isEqualTo: d.id).count().get(),
        ]);
        final score = (results[0].count ?? 0) + (results[1].count ?? 0) + (results[2].count ?? 0);
        return MapEntry(d, score);
      }));

      scores.sort((a, b) => b.value.compareTo(a.value));
      return Result.success(scores.take(limit).map((e) => e.key).toList());
    } catch (e, st) {
      appLogger.e('getTrending failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Stream<List<Decision>> watchFollowing({required String userId, int limit = 20}) {
    return _firestore.collection('follows').where('followerId', isEqualTo: userId).snapshots().asyncExpand((
      followsSnap,
    ) {
      final authorIds = followsSnap.docs.map((d) => d.data()['followingId'] as String).toSet().toList();
      if (authorIds.isEmpty) return Stream.value(<Decision>[]);

      // whereIn admite hasta 30 valores; suficiente para el volumen de la beta.
      final capped = authorIds.take(30).toList();
      return _firestore
          .collection('decisions')
          .where('authorId', whereIn: capped)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map(_fromDoc).toList());
    });
  }

  @override
  Stream<List<Decision>> watchByCategory({required String category, int limit = 20}) {
    return _firestore
        .collection('decisions')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }
}

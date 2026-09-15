import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/repositories/vote_repository.dart';

class VoteRepositoryImpl implements VoteRepository {
  VoteRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String _voteId(String userId, String decisionId) => '${userId}_$decisionId';

  @override
  Future<Result<String?>> getMyVote({required String userId, required String decisionId}) async {
    try {
      final doc = await _firestore.collection('votes').doc(_voteId(userId, decisionId)).get();
      if (!doc.exists) return const Result.success(null);
      return Result.success(doc.data()?['optionId'] as String?);
    } catch (e, st) {
      appLogger.e('getMyVote failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> castVote({
    required String userId,
    required String decisionId,
    required String optionId,
  }) async {
    try {
      await _firestore.collection('votes').doc(_voteId(userId, decisionId)).set({
        'userId': userId,
        'decisionId': decisionId,
        'optionId': optionId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Result.success(null);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return const Result.failure(ValidationFailure('Ya votaste en esta decisión.'));
      }
      appLogger.e('castVote failed', error: e);
      return const Result.failure(UnknownFailure());
    } catch (e, st) {
      appLogger.e('castVote failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<Set<String>>> getMyVotedDecisionIds(String userId) async {
    try {
      final snap = await _firestore.collection('votes').where('userId', isEqualTo: userId).get();
      return Result.success(snap.docs.map((d) => d.data()['decisionId'] as String).toSet());
    } catch (e, st) {
      appLogger.e('getMyVotedDecisionIds failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<Map<String, int>>> getVoteCountsByOption(String decisionId) async {
    try {
      final optionsSnap =
          await _firestore.collection('decisions').doc(decisionId).collection('options').get();

      final counts = await Future.wait(optionsSnap.docs.map((option) async {
        final countSnap = await _firestore
            .collection('votes')
            .where('decisionId', isEqualTo: decisionId)
            .where('optionId', isEqualTo: option.id)
            .count()
            .get();
        return MapEntry(option.id, countSnap.count ?? 0);
      }));

      return Result.success(Map.fromEntries(counts));
    } catch (e, st) {
      appLogger.e('getVoteCountsByOption failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }
}

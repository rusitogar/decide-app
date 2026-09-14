import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/repositories/save_repository.dart';

class SaveRepositoryImpl implements SaveRepository {
  SaveRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String _id(String userId, String decisionId) => '${userId}_$decisionId';

  @override
  Future<Result<bool>> isSaved({required String userId, required String decisionId}) async {
    try {
      final doc = await _firestore.collection('saves').doc(_id(userId, decisionId)).get();
      return Result.success(doc.exists);
    } catch (e, st) {
      appLogger.e('isSaved failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> save({required String userId, required String decisionId}) async {
    try {
      await _firestore.collection('saves').doc(_id(userId, decisionId)).set({
        'userId': userId,
        'decisionId': decisionId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('save failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> unsave({required String userId, required String decisionId}) async {
    try {
      await _firestore.collection('saves').doc(_id(userId, decisionId)).delete();
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('unsave failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<List<String>>> listSavedDecisionIds(String userId) async {
    try {
      final snap = await _firestore
          .collection('saves')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return Result.success(snap.docs.map((d) => d.data()['decisionId'] as String).toList());
    } catch (e, st) {
      appLogger.e('listSavedDecisionIds failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }
}

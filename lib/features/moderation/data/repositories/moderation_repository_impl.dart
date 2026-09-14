import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/repositories/moderation_repository.dart';

class ModerationRepositoryImpl implements ModerationRepository {
  ModerationRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<Result<void>> createReport({
    required String reporterId,
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      return const Result.failure(ValidationFailure('Contanos brevemente el motivo.'));
    }
    try {
      await _firestore.collection('reports').add({
        'reporterId': reporterId,
        'targetType': targetType.name,
        'targetId': targetId,
        'reason': reason.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('createReport failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> blockUser({required String ownerUid, required String blockedUid}) async {
    try {
      await _firestore.collection('users').doc(ownerUid).collection('blocks').doc(blockedUid).set({
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('blockUser failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> unblockUser({required String ownerUid, required String blockedUid}) async {
    try {
      await _firestore.collection('users').doc(ownerUid).collection('blocks').doc(blockedUid).delete();
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('unblockUser failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<bool>> isBlocked({required String ownerUid, required String blockedUid}) async {
    try {
      final doc =
          await _firestore.collection('users').doc(ownerUid).collection('blocks').doc(blockedUid).get();
      return Result.success(doc.exists);
    } catch (e, st) {
      appLogger.e('isBlocked failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<List<String>>> listBlockedUserIds(String ownerUid) async {
    try {
      final snap = await _firestore.collection('users').doc(ownerUid).collection('blocks').get();
      return Result.success(snap.docs.map((d) => d.id).toList());
    } catch (e, st) {
      appLogger.e('listBlockedUserIds failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }
}

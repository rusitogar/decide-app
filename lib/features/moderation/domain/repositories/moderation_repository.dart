import '../../../../core/error/result.dart';

enum ReportTargetType { decision, comment, user }

abstract interface class ModerationRepository {
  Future<Result<void>> createReport({
    required String reporterId,
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
  });

  Future<Result<void>> blockUser({required String ownerUid, required String blockedUid});

  Future<Result<void>> unblockUser({required String ownerUid, required String blockedUid});

  Future<Result<bool>> isBlocked({required String ownerUid, required String blockedUid});

  Future<Result<List<String>>> listBlockedUserIds(String ownerUid);
}

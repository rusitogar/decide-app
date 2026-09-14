import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/profile_counts.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

/// Normaliza un username a minúsculas/trim, la forma en la que se guarda
/// tanto en `users/{uid}.username` como en el id de `usernames/{username}`.
String normalizeUsername(String raw) => raw.trim().toLowerCase();

final _usernamePattern = RegExp(r'^[a-z0-9_]{3,20}$');

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  UserProfile _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return UserProfile(
      uid: doc.id,
      username: data['username'] as String? ?? doc.id,
      displayName: data['displayName'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      avatarColor: data['avatarColor'] as int? ?? _defaultColorFor(doc.id),
    );
  }

  static int _defaultColorFor(String uid) {
    const palette = [0xFF6750A4, 0xFF386A20, 0xFFB3261E, 0xFF00629E, 0xFF7D5260];
    return palette[uid.hashCode.abs() % palette.length];
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => doc.exists ? _fromDoc(doc) : null,
        );
  }

  @override
  Future<Result<ProfileCounts>> getProfileCounts(String uid) async {
    try {
      final results = await Future.wait([
        _firestore.collection('follows').where('followingId', isEqualTo: uid).count().get(),
        _firestore.collection('follows').where('followerId', isEqualTo: uid).count().get(),
        _firestore.collection('decisions').where('authorId', isEqualTo: uid).count().get(),
      ]);

      return Result.success(ProfileCounts(
        followers: results[0].count ?? 0,
        following: results[1].count ?? 0,
        decisions: results[2].count ?? 0,
      ));
    } catch (e, st) {
      appLogger.e('getProfileCounts failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<bool>> isUsernameAvailable(String username, {required String currentUid}) async {
    final normalized = normalizeUsername(username);
    try {
      final doc = await _firestore.collection('usernames').doc(normalized).get();
      if (!doc.exists) return const Result.success(true);
      return Result.success(doc.data()?['uid'] == currentUid);
    } catch (e, st) {
      appLogger.e('isUsernameAvailable failed', error: e, stackTrace: st);
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> updateProfile({
    required String uid,
    required String username,
    required String displayName,
    required String bio,
    required int avatarColor,
    String? avatarUrl,
  }) async {
    final normalized = normalizeUsername(username);
    if (!_usernamePattern.hasMatch(normalized)) {
      return const Result.failure(
        ValidationFailure('El usuario debe tener 3-20 caracteres: letras, números o _'),
      );
    }

    final userRef = _firestore.collection('users').doc(uid);
    final newUsernameRef = _firestore.collection('usernames').doc(normalized);

    try {
      // No lanzar excepciones propias dentro de runTransaction: en la
      // implementación web, el error cruza un puente de interop con JS y
      // pierde su tipo Dart original (siempre llega como error genérico al
      // catch de afuera). En cambio, la transacción devuelve un resultado
      // simple que se interpreta después.
      final usernameTaken = await _firestore.runTransaction<bool>((tx) async {
        final userSnap = await tx.get(userRef);
        final oldUsername = userSnap.data()?['username'] as String?;

        if (oldUsername != normalized) {
          final newUsernameSnap = await tx.get(newUsernameRef);
          if (newUsernameSnap.exists && newUsernameSnap.data()?['uid'] != uid) {
            return true;
          }

          // Todos los reads de la transacción deben ir antes que los writes:
          // hay que confirmar que la reserva vieja existe antes de borrarla
          // (por ejemplo, el username inicial al registrarse -el uid- nunca
          // tuvo una reserva propia en `usernames`).
          DocumentSnapshot<Map<String, dynamic>>? oldUsernameSnap;
          if (oldUsername != null && oldUsername.isNotEmpty) {
            oldUsernameSnap = await tx.get(_firestore.collection('usernames').doc(oldUsername));
          }

          if (oldUsernameSnap != null && oldUsernameSnap.exists) {
            tx.delete(oldUsernameSnap.reference);
          }
          tx.set(newUsernameRef, {'uid': uid});
        }

        tx.update(userRef, {
          'username': normalized,
          'displayName': displayName.trim(),
          'bio': bio.trim(),
          'avatarColor': avatarColor,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        });

        return false;
      });

      if (usernameTaken) {
        return const Result.failure(ValidationFailure('Ese nombre de usuario ya está en uso.'));
      }
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('updateProfile failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }
}

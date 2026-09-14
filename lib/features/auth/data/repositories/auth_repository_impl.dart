import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_failure_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(uid: user.uid, email: user.email, emailVerified: user.emailVerified);
  }

  @override
  Stream<AppUser?> authStateChanges() => _auth.authStateChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Future<Result<AppUser>> signUp({required String email, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return const Result.failure(UnknownFailure());

      // TODO(fase-1-blaze): mover esto a la Cloud Function onAuthUserCreate
      // cuando se active Blaze, para no depender del cliente.
      await _firestore.collection('users').doc(user.uid).set({
        'username': user.uid,
        'displayName': '',
        'avatarUrl': '',
        'bio': '',
        'followersCount': 0,
        'followingCount': 0,
        'decisionsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Result.success(_toAppUser(user)!);
    } on FirebaseAuthException catch (e) {
      return Result.failure(mapFirebaseAuthException(e));
    } catch (e, st) {
      appLogger.e('signUp failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<AppUser>> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _toAppUser(credential.user);
      if (user == null) return const Result.failure(UnknownFailure());
      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      return Result.failure(mapFirebaseAuthException(e));
    } catch (e, st) {
      appLogger.e('signIn failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Result.success(null);
    } catch (e, st) {
      appLogger.e('signOut failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(mapFirebaseAuthException(e));
    } catch (e, st) {
      appLogger.e('sendPasswordResetEmail failed', error: e, stackTrace: st);
      return const Result.failure(UnknownFailure());
    }
  }
}

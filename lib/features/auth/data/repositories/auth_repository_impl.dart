import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  /// Crea el perfil en `users/{uid}` si todavía no existe (no lo pisa si ya
  /// está, por ejemplo si el usuario ya se había registrado antes con este
  /// mismo email por otro método).
  Future<void> _ensureProfile(User user, {String? displayName, String? photoUrl}) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;

    // TODO(fase-1-blaze): mover esto a la Cloud Function onAuthUserCreate
    // cuando se active Blaze, para no depender del cliente.
    await ref.set({
      'username': user.uid,
      'displayName': displayName ?? user.displayName ?? '',
      // Fotos de Google/Microsoft son URLs externas (no Firebase Storage),
      // así que se pueden mostrar ya mismo sin necesitar Blaze.
      'avatarUrl': photoUrl ?? user.photoURL ?? '',
      'bio': '',
      'followersCount': 0,
      'followingCount': 0,
      'decisionsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Result<AppUser>> signUp({required String email, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return const Result.failure(UnknownFailure());

      await _ensureProfile(user);

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
  Future<Result<AppUser?>> signInWithOAuth(OAuthProviderType type) async {
    final provider = switch (type) {
      OAuthProviderType.google => GoogleAuthProvider(),
      OAuthProviderType.microsoft => OAuthProvider('microsoft.com'),
    };

    try {
      final credential = kIsWeb
          ? await _auth.signInWithPopup(provider)
          : await _auth.signInWithProvider(provider);

      final user = credential.user;
      if (user == null) return const Result.failure(UnknownFailure());

      await _ensureProfile(user);

      return Result.success(_toAppUser(user));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request' || e.code == 'canceled') {
        return const Result.success(null);
      }
      return Result.failure(mapFirebaseAuthException(e));
    } catch (e, st) {
      appLogger.e('signInWithOAuth failed', error: e, stackTrace: st);
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

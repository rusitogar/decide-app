import '../../../../core/error/result.dart';
import '../entities/app_user.dart';

enum OAuthProviderType { google, microsoft }

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<Result<AppUser>> signUp({required String email, required String password});

  Future<Result<AppUser>> signIn({required String email, required String password});

  /// `Result.success(null)` significa que el usuario cerró el selector de
  /// cuenta sin elegir ninguna (no es un error, no hay que mostrar mensaje).
  Future<Result<AppUser?>> signInWithOAuth(OAuthProviderType provider);

  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordResetEmail(String email);
}

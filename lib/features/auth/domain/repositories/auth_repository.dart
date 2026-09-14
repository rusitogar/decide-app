import '../../../../core/error/result.dart';
import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<Result<AppUser>> signUp({required String email, required String password});

  Future<Result<AppUser>> signIn({required String email, required String password});

  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordResetEmail(String email);
}

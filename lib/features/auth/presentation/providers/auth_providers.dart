import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signIn(email: email, password: password);
    state = const AsyncData(null);
    return result.when(success: (_) => null, failure: (f) => f);
  }

  Future<Failure?> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signUp(email: email, password: password);
    state = const AsyncData(null);
    return result.when(success: (_) => null, failure: (f) => f);
  }

  Future<Failure?> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    state = const AsyncData(null);
    return result.when(success: (_) => null, failure: (f) => f);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);

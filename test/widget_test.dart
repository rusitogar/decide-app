import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:decide/app.dart';
import 'package:decide/core/error/result.dart';
import 'package:decide/features/auth/domain/entities/app_user.dart';
import 'package:decide/features/auth/domain/repositories/auth_repository.dart';
import 'package:decide/features/auth/presentation/providers/auth_providers.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> authStateChanges() => Stream.value(null);

  @override
  AppUser? get currentUser => null;

  @override
  Future<Result<AppUser>> signUp({required String email, required String password, String? username}) async =>
      throw UnimplementedError();

  @override
  Future<Result<AppUser>> signIn({required String email, required String password}) async =>
      throw UnimplementedError();

  @override
  Future<Result<AppUser?>> signInWithOAuth(OAuthProviderType provider) async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> signOut() async => const Result.success(null);

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async => throw UnimplementedError();
}

void main() {
  testWidgets('Shows the sign-in screen when there is no session', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(_FakeAuthRepository())],
        child: const DecideApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('DECIDE'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}

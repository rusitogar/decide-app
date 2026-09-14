import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:decide/features/auth/data/auth_failure_mapper.dart';

void main() {
  test('maps known Firebase Auth error codes to friendly Spanish messages', () {
    final result = mapFirebaseAuthException(FirebaseAuthException(code: 'wrong-password'));
    expect(result.message, 'Email o contraseña incorrectos.');
  });

  test('falls back to a generic message for unknown error codes', () {
    final result = mapFirebaseAuthException(FirebaseAuthException(code: 'something-unexpected'));
    expect(result.message, 'No se pudo completar la operación. Intentá de nuevo.');
  });
}

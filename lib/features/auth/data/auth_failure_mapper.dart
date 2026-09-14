import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/error/failure.dart';

AuthFailure mapFirebaseAuthException(FirebaseAuthException e) {
  final message = switch (e.code) {
    'email-already-in-use' => 'Ese email ya tiene una cuenta creada.',
    'invalid-email' => 'El email no es válido.',
    'weak-password' => 'La contraseña es muy débil (mínimo 6 caracteres).',
    'user-not-found' => 'No existe una cuenta con ese email.',
    'wrong-password' || 'invalid-credential' => 'Email o contraseña incorrectos.',
    'user-disabled' => 'Esta cuenta fue deshabilitada.',
    'too-many-requests' => 'Demasiados intentos. Probá de nuevo en unos minutos.',
    'network-request-failed' => 'Error de conexión. Revisá tu internet.',
    _ => 'No se pudo completar la operación. Intentá de nuevo.',
  };
  return AuthFailure(message);
}

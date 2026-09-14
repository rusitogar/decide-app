import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Error de conexión. Revisá tu internet.']);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'No se encontró lo que buscabas.']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'No tenés permiso para hacer esto.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ocurrió un error inesperado.']);
}

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class UnauthorizedRoleFailure extends Failure {
  const UnauthorizedRoleFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UserDisabledFailure extends Failure {
  const UserDisabledFailure() : super('Your account has been deactivated. Please contact your administrator.');
}

class RequiresRecentLoginFailure extends Failure {
  const RequiresRecentLoginFailure() : super('Please sign in again to perform this action.');
}

class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure() : super('Please verify your email before continuing.');
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class DuplicateEmailFailure extends Failure {
  const DuplicateEmailFailure(super.message);
}

class OperationNotAllowedFailure extends Failure {
  const OperationNotAllowedFailure(super.message);
}

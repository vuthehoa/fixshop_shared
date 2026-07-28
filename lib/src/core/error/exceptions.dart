class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'An unexpected server error occurred.']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed.']);
}

class UserDisabledException implements Exception {
  const UserDisabledException();
}

class RequiresRecentLoginException implements Exception {
  const RequiresRecentLoginException();
}

class EmailNotVerifiedException implements Exception {
  const EmailNotVerifiedException();
}

class UnauthorizedRoleException implements Exception {
  final String message;
  const UnauthorizedRoleException([this.message = 'Access denied for this role.']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error. Please check your connection.']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Local storage error.']);
}

class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'File storage error.']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Record not found.']);
}

class DuplicateEmailException implements Exception {
  final String message;
  const DuplicateEmailException([this.message = 'An account with this email already exists.']);
}

class OperationNotAllowedException implements Exception {
  final String message;
  const OperationNotAllowedException([this.message = 'This operation is not allowed.']);
}

/// Base class for all domain-level failures.
///
/// Subclasses represent specific categories of errors that can occur
/// during repository operations, allowing the presentation layer to
/// handle errors without depending on technical exception types.
sealed class Failure {
  const Failure(this.message);

  /// A human-readable description of the failure.
  final String message;
}

/// Failure originating from a database operation.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Failure indicating that a requested resource was not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Failure originating from a network or HTTP transport error.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure indicating that the user is not authenticated or the session expired.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

/// Failure indicating that input did not pass server-side validation.
///
/// [fieldErrors] maps field names to their validation messages so the UI can
/// surface per-field feedback without parsing raw error strings.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors = const {}});

  /// Per-field validation messages keyed by field name.
  final Map<String, String> fieldErrors;
}

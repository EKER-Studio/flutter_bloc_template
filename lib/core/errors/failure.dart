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
  /// Creates a [DatabaseFailure] with the given [message].
  const DatabaseFailure(super.message);
}

/// Failure indicating that a requested resource was not found.
class NotFoundFailure extends Failure {
  /// Creates a [NotFoundFailure] with the given [message].
  const NotFoundFailure(super.message);
}

/// Failure originating from a network or HTTP transport error.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure] with the given [message].
  const NetworkFailure(super.message);
}

/// Failure indicating that the user is not authenticated or the session expired.
class UnauthorizedFailure extends Failure {
  /// Creates an [UnauthorizedFailure] with the given [message].
  const UnauthorizedFailure(super.message);
}

/// Failure indicating that input did not pass server-side validation.
///
/// [fieldErrors] maps field names to their validation messages so the UI can
/// surface per-field feedback without parsing raw error strings.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure] with the given [message] and optional
  /// per-field [fieldErrors].
  const ValidationFailure(super.message, {this.fieldErrors = const {}});

  /// Per-field validation messages keyed by field name.
  final Map<String, String> fieldErrors;
}

/// Maps each [Failure] to text that is safe to show directly to end users.
///
/// [Failure.message] may contain raw exception text (useful for logs/crash
/// reports) — this extension hides that behind a stable, friendly string per
/// failure category.
extension FailureUserMessage on Failure {
  /// A human-readable message safe to display in UI.
  String get userMessage => switch (this) {
    NotFoundFailure() => 'This item no longer exists.',
    DatabaseFailure() =>
      'Something went wrong while saving your data. Please try again.',
    NetworkFailure() =>
      'A network error occurred. Please check your connection and try again.',
    UnauthorizedFailure() => 'Your session has expired. Please sign in again.',
    ValidationFailure() => 'Some fields contain invalid values.',
  };
}

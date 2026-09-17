import 'failure.dart';

/// Type alias for command and mutation operations returning a success flag and an optional [Failure].
typedef CommandResult = (bool success, Failure? failure);

/// Type alias for query and retrieval operations returning optional data of type [T] and an optional [Failure].
typedef DataResult<T> = (T? data, Failure? failure);

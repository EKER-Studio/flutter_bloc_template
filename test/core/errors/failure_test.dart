import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';

void main() {
  group('Failure hierarchy', () {
    test('DatabaseFailure stores message', () {
      const failure = DatabaseFailure('db error');
      expect(failure.message, 'db error');
    });

    test('NotFoundFailure stores message', () {
      const failure = NotFoundFailure('not found');
      expect(failure.message, 'not found');
    });

    test('NetworkFailure stores message', () {
      const failure = NetworkFailure('network timeout');
      expect(failure.message, 'network timeout');
    });

    test('UnauthorizedFailure stores message', () {
      const failure = UnauthorizedFailure('session expired');
      expect(failure.message, 'session expired');
    });

    test(
      'ValidationFailure stores message and defaults to empty fieldErrors',
      () {
        const failure = ValidationFailure('invalid data');
        expect(failure.message, 'invalid data');
        expect(failure.fieldErrors, isEmpty);
      },
    );

    test('ValidationFailure stores custom fieldErrors', () {
      const fieldErrors = {'title': 'Title cannot be empty'};
      const failure = ValidationFailure(
        'validation failed',
        fieldErrors: fieldErrors,
      );
      expect(failure.message, 'validation failed');
      expect(failure.fieldErrors, fieldErrors);
    });
  });
}

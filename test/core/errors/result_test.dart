import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result typedefs', () {
    test('CommandResult supports successful outcome', () {
      const CommandResult result = (true, null);

      final (success, failure) = result;
      expect(success, isTrue);
      expect(failure, isNull);
    });

    test('CommandResult supports failure outcome', () {
      const CommandResult result = (
        false,
        DatabaseFailure('Failed to save entity'),
      );

      final (success, failure) = result;
      expect(success, isFalse);
      expect(failure, isA<DatabaseFailure>());
      expect(failure?.message, 'Failed to save entity');
    });

    test('DataResult supports successful retrieval with payload', () {
      const DataResult<String> result = ('user_data', null);

      final (data, failure) = result;
      expect(data, 'user_data');
      expect(failure, isNull);
    });

    test('DataResult supports failure retrieval', () {
      const DataResult<String> result = (
        null,
        NotFoundFailure('Entity does not exist'),
      );

      final (data, failure) = result;
      expect(data, isNull);
      expect(failure, isA<NotFoundFailure>());
      expect(failure?.message, 'Entity does not exist');
    });
  });
}

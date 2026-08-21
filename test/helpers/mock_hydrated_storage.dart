import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

/// Mock implementation of [Storage] for testing HydratedBlocs.
class MockStorage extends Mock implements Storage {}

/// Initializes [HydratedBloc.storage] with a [MockStorage] instance for unit tests.
Storage initMockHydratedStorage() {
  final storage = MockStorage();
  when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
  when(() => storage.read(any())).thenReturn(null);
  when(() => storage.delete(any())).thenAnswer((_) async {});
  when(() => storage.clear()).thenAnswer((_) async {});
  when(() => storage.close()).thenAnswer((_) async {});
  HydratedBloc.storage = storage;
  return storage;
}

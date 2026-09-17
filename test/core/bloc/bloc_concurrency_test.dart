import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

sealed class TestConcurrencyEvent {}

class IncrementEvent extends TestConcurrencyEvent {
  IncrementEvent(this.value);
  final int value;
}

class TestConcurrencyBloc extends Bloc<TestConcurrencyEvent, int> {
  TestConcurrencyBloc() : super(0) {
    on<IncrementEvent>((event, emit) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      emit(state + event.value);
    }, transformer: droppable());
  }
}

void main() {
  group('bloc_concurrency droppable transformer', () {
    blocTest<TestConcurrencyBloc, int>(
      'drops events received while previous event is actively processing',
      build: TestConcurrencyBloc.new,
      act: (bloc) async {
        bloc.add(IncrementEvent(1));
        // Immediately add another before delay elapses — should be dropped.
        bloc.add(IncrementEvent(2));
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // Add after delay elapses — should be processed.
        bloc.add(IncrementEvent(3));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [1, 4],
    );
  });
}

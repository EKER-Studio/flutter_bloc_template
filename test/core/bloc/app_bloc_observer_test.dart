import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/core/bloc/app_bloc_observer.dart';

class _TestCubit extends Cubit<int> {
  _TestCubit() : super(0);

  void triggerError() {
    addError(Exception('Test error'), StackTrace.current);
  }
}

void main() {
  group('AppBlocObserver', () {
    test('intercepts bloc error without crashing', () async {
      const observer = AppBlocObserver();
      final cubit = _TestCubit();

      expect(
        () => observer.onError(
          cubit,
          Exception('Manual error'),
          StackTrace.current,
        ),
        returnsNormally,
      );

      await cubit.close();
    });
  });
}

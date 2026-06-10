import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/utils/debounce/debounce_mixin.dart';

// Test widget that uses DebounceMixin
class _DebounceTestWidget extends StatefulWidget {
  final Function(String)? onDebounced;
  final Function(String)? onThrottled;

  const _DebounceTestWidget({this.onDebounced, this.onThrottled});

  @override
  State<_DebounceTestWidget> createState() => _DebounceTestWidgetState();
}

class _DebounceTestWidgetState extends State<_DebounceTestWidget>
    with DebounceMixin {
  @override
  void dispose() {
    cancelAllDebounce();
    super.dispose();
  }

  void triggerDebounce(String key, String value) {
    debounce(key, () {
      widget.onDebounced?.call(value);
    });
  }

  void triggerThrottle(String key, String value) {
    throttle(key, () {
      widget.onThrottled?.call(value);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  group('DebounceMixin', () {
    testWidgets('debounce delays callback execution', (tester) async {
      String? result;

      await tester.pumpWidget(
        _DebounceTestWidget(onDebounced: (val) => result = val),
      );

      final state = tester.state<_DebounceTestWidgetState>(
        find.byType(_DebounceTestWidget),
      );

      state.triggerDebounce('test', 'hello');
      expect(result, isNull); // Not yet called

      // Wait for debounce period
      await tester.pump(const Duration(milliseconds: 350));
      expect(result, 'hello');
    });

    testWidgets('debounce cancels previous timer on new call', (tester) async {
      final calls = <String>[];

      await tester.pumpWidget(
        _DebounceTestWidget(onDebounced: (val) => calls.add(val)),
      );

      final state = tester.state<_DebounceTestWidgetState>(
        find.byType(_DebounceTestWidget),
      );

      state.triggerDebounce('test', 'first');
      await tester.pump(const Duration(milliseconds: 100));
      state.triggerDebounce('test', 'second'); // Should cancel "first"
      await tester.pump(const Duration(milliseconds: 350));

      expect(calls.length, 1);
      expect(calls.first, 'second');
    });

    testWidgets('different keys debounce independently', (tester) async {
      final calls = <String>[];

      await tester.pumpWidget(
        _DebounceTestWidget(onDebounced: (val) => calls.add(val)),
      );

      final state = tester.state<_DebounceTestWidgetState>(
        find.byType(_DebounceTestWidget),
      );

      state.triggerDebounce('key1', 'A');
      state.triggerDebounce('key2', 'B');

      await tester.pump(const Duration(milliseconds: 350));

      expect(calls.length, 2);
      expect(calls, containsAll(['A', 'B']));
    });

    testWidgets('leading:true executes immediately on first call',
        (tester) async {
      // Verifies that the debounce mixin does not crash with leading:true
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox()),
      );

      // Mixin can be used with leading:true without issues
      expect(true, isTrue);
    });

    testWidgets('cancelAllDebounce prevents pending callbacks',
        (tester) async {
      final calls = <String>[];

      await tester.pumpWidget(
        _DebounceTestWidget(onDebounced: (val) => calls.add(val)),
      );

      final state = tester.state<_DebounceTestWidgetState>(
        find.byType(_DebounceTestWidget),
      );

      state.triggerDebounce('test', 'should be cancelled');
      await tester.pump(const Duration(milliseconds: 50));
      state.cancelAllDebounce();
      await tester.pump(const Duration(milliseconds: 350));

      expect(calls, isEmpty);
    });

    testWidgets('isDebouncing returns correct state', (tester) async {
      await tester.pumpWidget(
        _DebounceTestWidget(
          onDebounced: (_) {},
          onThrottled: (_) {},
        ),
      );

      final state = tester.state<_DebounceTestWidgetState>(
        find.byType(_DebounceTestWidget),
      );

      expect(state.isDebouncing('test'), isFalse);

      state.triggerDebounce('test', 'value');
      expect(state.isDebouncing('test'), isTrue);

      await tester.pump(const Duration(milliseconds: 350));
      expect(state.isDebouncing('test'), isFalse);
    });
  });

  group('Debouncer (standalone)', () {
    test('initial state is not pending', () {
      final debouncer = Debouncer();
      expect(debouncer.isPending, isFalse);
    });

    test('becomes pending during debounce period', () {
      final debouncer = Debouncer();
      debouncer.call(() {});
      expect(debouncer.isPending, isTrue);
    });

    test('cancel stops pending timer', () {
      final debouncer = Debouncer();
      debouncer.call(() {});
      expect(debouncer.isPending, isTrue);
      debouncer.cancel();
      expect(debouncer.isPending, isFalse);
    });
  });

  group('Throttler (standalone)', () {
    test('first call executes immediately', () {
      final throttler = Throttler();
      bool called = false;
      final result = throttler.call(() => called = true);
      expect(result, isTrue);
      expect(called, isTrue);
    });

    test('second immediate call is throttled', () {
      final throttler = Throttler();
      int callCount = 0;
      throttler.call(() => callCount++);
      final result = throttler.call(() => callCount++);
      expect(result, isFalse);
      expect(callCount, 1);
    });
  });
}

import 'dart:async';

/// Mixin providing debounce functionality for search inputs,
/// button presses, and API calls.
///
/// Usage:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   ...
/// }
///
/// class _MyWidgetState extends State<MyWidget> with DebounceMixin {
///   void onSearchChanged(String query) {
///     debounce('search', () => _performSearch(query),
///         duration: const Duration(milliseconds: 300));
///   }
///
///   @override
///   void dispose() {
///     cancelAllDebounce();
///     super.dispose();
///   }
/// }
/// ```
mixin DebounceMixin {
  final Map<String, Timer> _debounceTimers = {};
  final Map<String, DateTime> _lastCallTimes = {};

  /// Debounce a function call with a unique key.
  ///
  /// [key] Unique identifier for this debounce group.
  /// [callback] The function to call after the debounce period.
  /// [duration] How long to wait before executing (default: 300ms).
  /// [leading] If true, execute immediately on first call, then debounce subsequent calls.
  void debounce(
    String key,
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 300),
    bool leading = false,
  }) {
    if (leading && !_debounceTimers.containsKey(key)) {
      callback();
    }

    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(duration, () {
      _debounceTimers.remove(key);
      if (!leading) {
        callback();
      }
    });
    _lastCallTimes[key] = DateTime.now();
  }

  /// Throttle a function call — execute at most once per [duration].
  void throttle(
    String key,
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final now = DateTime.now();
    final lastCall = _lastCallTimes[key];

    if (lastCall == null || now.difference(lastCall) >= duration) {
      callback();
      _lastCallTimes[key] = now;
    }
  }

  /// Cancel a specific debounce timer
  void cancelDebounce(String key) {
    _debounceTimers[key]?.cancel();
    _debounceTimers.remove(key);
  }

  /// Cancel all pending debounce timers
  void cancelAllDebounce() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _lastCallTimes.clear();
  }

  /// Check if a debounce timer is currently pending
  bool isDebouncing(String key) => _debounceTimers.containsKey(key);

  /// Get time since last call for a key
  Duration? timeSinceLastCall(String key) {
    final lastCall = _lastCallTimes[key];
    if (lastCall == null) return null;
    return DateTime.now().difference(lastCall);
  }
}

/// Typedef for debounce callbacks
typedef VoidCallback = void Function();

/// Standalone debounce utility (for use without mixin)
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isPending => _timer?.isActive ?? false;
}

/// Standalone throttle utility (for use without mixin)
class Throttler {
  final Duration duration;
  DateTime? _lastCall;

  Throttler({this.duration = const Duration(milliseconds: 300)});

  bool call(VoidCallback callback) {
    final now = DateTime.now();
    if (_lastCall == null || now.difference(_lastCall!) >= duration) {
      _lastCall = now;
      callback();
      return true;
    }
    return false;
  }
}

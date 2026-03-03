import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core.dart';

/// A function type that represents a code block in a Flutter widget test,
/// providing access to both the [BddContext] and the [WidgetTester].
typedef WidgetTestCallback = FutureOr<void> Function(
    BddContext ctx, WidgetTester tester);

/// Extension to enable running Flutter UI tests directly via `testWidgets`.
///
/// Use this entry point when you are writing Flutter Widget tests that require
/// a [WidgetTester] to interact with the UI.
extension FlutterWidgetTestRun on BddRunnable {
  /// Executes the BDD scenario as a Flutter widget test.
  ///
  /// This method natively uses `testWidgets` from `package:flutter_test`.
  void run([WidgetTestCallback? testCallback]) {
    BddRunner().run(
      bdd,
      (ctx) async {
        if (testCallback != null) {
          final tester = Zone.current[#tester] as WidgetTester?;
          if (tester == null) {
            throw StateError('WidgetTester not found in context. '
                'Did you forget to use ".run()" imported from `bdd_flutter_widget_test.dart` at the end of the scenario?');
          }
          await testCallback(ctx, tester);
        }
      },
      _testDelegate,
      _errorHandler,
    );
  }
}

/// Extension to attach Flutter-specific executable closures (code blocks) to BDD terms.
///
/// By importing `bdd_flutter_widget_test.dart`, these extensions become available,
/// allowing you to access the [WidgetTester] in every step.
extension FlutterWidgetTestCode<C> on BddCodeable<C> {
  /// Attaches a code block that injects the [WidgetTester] directly into the callback.
  ///
  /// The [codeRun] function receives both the [BddContext] and the [WidgetTester]
  /// currently active for the test.
  C code(WidgetTestCallback testCallback) {
    return addCode((ctx) async {
      final tester = Zone.current[#tester] as WidgetTester?;
      if (tester == null) {
        throw StateError('WidgetTester not found in context. '
            'Did you forget to use ".run()" imported from `bdd_flutter_widget_test.dart` at the end of the scenario?');
      }
      await testCallback(ctx, tester);
    });
  }
}

/// A runner that injects the tester into the context.
void _testDelegate(
  String description,
  Future<void> Function() body, {
  Timeout? timeout,
  bool? skip,
  dynamic tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
  dynamic testOn,
}) {
  testWidgets(
    description,
    (tester) async {
      if (BddFlutter.ignoreOverflow) _ignoreOverflowErrors();
      try {
        // To pass the tester down to the `CodeRun` context during the execution phase,
        // we can use a Zone.
        await runZoned(
          () async {
            await body();
          },
          zoneValues: {#tester: tester},
        );
      } finally {
        _cleanTargetPlatformOverride();
      }
    },
    skip: skip,
    timeout: timeout,
    tags: tags,
    retry: retry,
  );
}

void _errorHandler(Object error, StackTrace stackTrace) {
  var errorDetails = FlutterErrorDetails(
    library: 'BDD Framework',
    exception: error,
    stack: stackTrace,
    stackFilter: _stackFilter,
  );
  reportTestException(errorDetails, "");
}

Iterable<String> _stackFilter(Iterable<String> frames) {
  // Removes the frames we are not interested in.
  var filteredFrames = frames.where((frame) =>
      !frame.contains("package:matcher/") &&
      !frame.contains("package:flutter_test/src/widget_tester.dart") &&
      !frame.contains("package:bdd_framework/src/") &&
      !frame.contains("package:test_api/src/"));

  return FlutterError.defaultStackFilter(filteredFrames);
}

void _ignoreOverflowErrors() {
  var handlerOriginal = FlutterError.onError;
  FlutterError.onError = (details) {
    var exception = details.exception;
    var ifOverflow = (exception is FlutterError) &&
        exception.diagnostics
            .map((diagnostic) => diagnostic.value)
            .whereType<List<Object>>()
            .expand((value) => value)
            .any((data) =>
                data.toString().startsWith("A RenderFlex overflowed by"));

    if (ifOverflow)
      FlutterError.dumpErrorToConsole(details);
    else
      handlerOriginal!(details);
  };
}

void _cleanTargetPlatformOverride() =>
    (debugDefaultTargetPlatformOverride = null);

class BddFlutter {
  static bool ignoreOverflow = true;
}

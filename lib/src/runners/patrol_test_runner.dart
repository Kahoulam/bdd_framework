import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../core.dart';

/// A function type that represents a code block in a Patrol integration test,
/// providing access to both the [BddContext] and the [PatrolIntegrationTester].
typedef PatrolTestCallback = FutureOr<void> Function(
    BddContext ctx, PatrolIntegrationTester $);

/// Extension providing the standard `.run()` method for Patrol BDD tests.
///
/// Use this entry point when you are writing integration tests that require
/// Patrol's native automation and enhanced finders.
extension PatrolTestRun on BddRunnable {
  /// Executes the BDD scenario as a Patrol integration test.
  ///
  /// This method injects the [PatrolIntegrationTester] directly into the `BddContext`
  /// and wraps the execution with [patrolTest].
  void run([PatrolTestCallback? testCallback]) {
    BddRunner().run(
      bdd,
      (ctx) async {
        if (testCallback != null) {
          final $ = Zone.current[#patrolTester] as PatrolIntegrationTester?;
          if ($ == null) {
            throw StateError('PatrolIntegrationTester not found in context. '
                'Did you forget to use ".run()" imported from `package:bdd_framework/patrol_test.dart` at the end of the scenario?');
          }
          await testCallback(ctx, $);
        }
      },
      _testDelegate,
      _errorHandler,
    );
  }
}

/// Extension to attach Patrol-specific executable closures (code blocks) to BDD terms.
///
/// By importing `patrol_test.dart`, these extensions become available,
/// allowing you to access the [PatrolIntegrationTester] (often named `$`) in every step.
extension PatrolTestCode<T> on BddCodeable<T> {
  /// Attaches a code block that injects the [PatrolIntegrationTester] directly into the callback.
  ///
  /// The [codeRun] function receives both the [BddContext] and the [PatrolIntegrationTester]
  /// currently active for the test.
  T code(PatrolTestCallback codeRun) {
    return addCode((ctx) async {
      final $ = Zone.current[#patrolTester] as PatrolIntegrationTester?;
      if ($ == null) {
        throw StateError('PatrolIntegrationTester not found in context. '
            'Did you forget to use ".run()" imported from `package:bdd_framework/patrol_test.dart` at the end of the scenario?');
      }
      await codeRun(ctx, $);
    });
  }
}

/// Internal helper that bridges the [BddRunner] to the Patrol [patrolTest] function.
void _testDelegate(
  String description,
  Future<void> Function() body, {
  dynamic timeout,
  bool? skip,
  dynamic tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
  dynamic testOn,
}) {
  patrolTest(
    description,
    ($) async {
      if (BddPatrol.ignoreOverflow) _ignoreOverflowErrors();
      try {
        await runZoned(
          () async {
            await body();
          },
          zoneValues: {#patrolTester: $},
        );
      } finally {
        _cleanTargetPlatformOverride();
      }
    },
    skip: skip,
    timeout: timeout,
    tags: tags,
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
      !frame.contains("package:flutter_test/") &&
      !frame.contains("package:patrol/") &&
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

/// Configuration for Patrol-specific BDD settings.
class BddPatrol {
  /// Whether to suppress RenderFlex overflow errors in logs.
  static bool ignoreOverflow = true;
}

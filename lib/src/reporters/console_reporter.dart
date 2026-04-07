import 'dart:io';

import '../core.dart';

class ConsoleReporter extends BddReporter {
  static const config = BddConfig(rightAlignKeywords: true);

  @override
  Future<void> report() async {
    int count = 0;

    for (BddFeature feature in features) {
      count++;
      stdout.writeln("$BddFeature $count --------------\n");
      if (feature.isNotEmpty) {
        var featureStr = feature.toString(config);
        stdout.writeln(featureStr);

        if (feature.backgroundFramework != null) {
          stdout.writeln(feature.background.toString(config));
        }
      }

      for (TestResult testResult in feature.testResults) {
        stdout.writeln(testResult.toString(config) + "\n");
      }
    }
  }
}

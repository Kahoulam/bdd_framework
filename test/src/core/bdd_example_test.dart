import 'package:bdd_framework/bdd_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BddExample Basic Rendering', () {
    test('renders examples keyword and rows correctly', () {
      final example = Bdd(BddFeature('Example Feature'))
          .scenario('Example Scenario')
          .given('a condition')
          .when('an action')
          .then('an outcome')
          .example(
            val('number', 123),
            val('password', 'abc'),
          )
          .example(
            val('number', 456),
            val('password', 'xyz'),
          );

      final output = example.toString(const BddConfig());
      expect(
        output,
        '    Examples: \n'
        '      | number | password |\n'
        '      | 123    | abc      |\n'
        '      | 456    | xyz      |',
      );
    });

    test('appends rows when chaining multiple example calls', () {
      final bdd = Bdd(BddFeature('Example Feature'))
          .scenario('Example Scenario')
          .given('a condition')
          .when('an action')
          .then('an outcome')
          .example(
            val('number', 123),
            val('password', 'abc'),
          )
          .example(
            val('number', 456),
            val('password', 'xyz'),
          );

      expect(bdd.rows, hasLength(2));
      expect(
        {for (final v in bdd.rows[0]) v.name: v.value},
        {'number': 123, 'password': 'abc'},
      );
      expect(
        {for (final v in bdd.rows[1]) v.name: v.value},
        {'number': 456, 'password': 'xyz'},
      );
    });
  });

  group('BddExample Config Integration', () {
    test('respects custom examples keyword from BddConfig', () {
      final example = Bdd(BddFeature('Example Feature'))
          .scenario('Example Scenario')
          .given('a condition')
          .when('an action')
          .then('an outcome')
          .example(val('欄位', '值'));

      const customConfig = BddConfig(
        keywords: BddKeywords(examples: '範例:'),
      );

      final output = example.toString(customConfig);
      expect(
        output,
        '    範例: \n'
        '      | 欄位 |\n'
        '      | 值  |',
      );
    });

    test('applies custom endOfLineChar correctly', () {
      final example = Bdd(BddFeature('Example Feature'))
          .scenario('Example Scenario')
          .given('a condition')
          .when('an action')
          .then('an outcome')
          .example(val('number', 123));

      const customConfig = BddConfig(endOfLineChar: '\r\n');

      final output = example.toString(customConfig);
      expect(output, '    Examples: \r\n      | number |\r\n      | 123    |');
    });
  });

  group('BddExample DSL Integration', () {
    test('allows examples after then and', () {
      final reporter = _TestBddReporter(const BddConfig());
      final seenExamples = <BddTableValues>[];

      Bdd(BddFeature('Example Feature'))
          .scenario('Example Scenario')
          .given('a condition')
          .when('an action')
          .then('an outcome')
          .and('another outcome')
          .example(
            val('number', 123),
            val('password', 'abc'),
          )
          .example(
            val('number', 456),
            val('password', 'xyz'),
          )
          .testRun((ctx) {
            seenExamples.add(ctx.example);
          }, reporter);

      expect(seenExamples, [
        BddTableValues({'number': 123, 'password': 'abc'}),
        BddTableValues({'number': 456, 'password': 'xyz'}),
      ]);
    });

    test('allows examples after then but', () {
      final reporter = _TestBddReporter(const BddConfig());
      final seenExamples = <BddTableValues>[];

      Bdd(BddFeature('Example Feature'))
          .scenario('Example Scenario')
          .given('a condition')
          .when('an action')
          .then('an outcome')
          .but('not a different outcome type')
          .example(
            val('number', 123),
            val('password', 'abc'),
          )
          .example(
            val('number', 456),
            val('password', 'xyz'),
          )
          .testRun((ctx) {
            seenExamples.add(ctx.example);
          }, reporter);

      expect(seenExamples, [
        BddTableValues({'number': 123, 'password': 'abc'}),
        BddTableValues({'number': 456, 'password': 'xyz'}),
      ]);
    });

    test('allows examples after then code and', () {
      final reporter = _TestBddReporter(const BddConfig());
      final seenExamples = <BddTableValues>[];

      Bdd(BddFeature('Example Feature'))
          .scenario('Example Scenario')
          .given('a condition')
          .when('an action')
          .then('an outcome')
          .code((_) {})
          .and('another outcome')
          .example(
            val('number', 123),
            val('password', 'abc'),
          )
          .example(
            val('number', 456),
            val('password', 'xyz'),
          )
          .testRun((ctx) {
            seenExamples.add(ctx.example);
          }, reporter);

      expect(seenExamples, [
        BddTableValues({'number': 123, 'password': 'abc'}),
        BddTableValues({'number': 456, 'password': 'xyz'}),
      ]);
    });

    test('allows examples after then code but', () {
      final reporter = _TestBddReporter(const BddConfig());
      final seenExamples = <BddTableValues>[];

      Bdd(BddFeature('Example Feature'))
          .scenario('Example Scenario')
          .given('a condition')
          .when('an action')
          .then('an outcome')
          .code((_) {})
          .but('not a different outcome type')
          .example(
            val('number', 123),
            val('password', 'abc'),
          )
          .example(
            val('number', 456),
            val('password', 'xyz'),
          )
          .testRun((ctx) {
            seenExamples.add(ctx.example);
          }, reporter);

      expect(seenExamples, [
        BddTableValues({'number': 123, 'password': 'abc'}),
        BddTableValues({'number': 456, 'password': 'xyz'}),
      ]);
    });
  });
}

class _TestBddReporter extends BddReporter {
  _TestBddReporter(this.config);

  final BddConfig config;

  @override
  Future<void> report() async {}
}

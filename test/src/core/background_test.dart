import 'package:bdd_framework/bdd_framework.dart';
import 'package:bdd_framework/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BddBackground Basic Rendering', () {
    test('renders only the Background keyword when there are no steps', () {
      final feature = BddFeature('Feature Without Steps');
      final background = feature.background;
      // Because we haven't added given steps, it should just be:
      // Background:\n
      final output = background.toString(const BddConfig());
      expect(output, '  Background:\n');
    });

    test('renders keyword and step correctly with a single step', () {
      final feature = BddFeature('Feature With Single Step');
      final background = feature.background;
      background.given('a condition');

      final output = background.toString(const BddConfig());
      expect(output, '  Background:\n    Given a condition\n');
    });

    test('maintains order and newlines with multiple steps', () {
      final feature = BddFeature('Feature With Multiple Steps');
      final background = feature.background;
      background.given('first step').and('second step').note('a comment');

      final output = background.toString(const BddConfig());
      expect(
        output,
        '  Background:\n'
        '    Given first step\n'
        '    And second step\n'
        '    # A comment\n',
      );
    });
  });

  group('BddBackground Config Integration', () {
    test('respects custom keywords from BddConfig', () {
      final feature = BddFeature('Custom Keyword Feature');
      final background = feature.background;
      background.given('初始化狀態');

      const customConfig = BddConfig(
        keywords: BddKeywords(
          background: '背景:',
          given: '假定',
        ),
      );

      final output = background.toString(customConfig);
      expect(output, '  背景:\n    假定 初始化狀態\n');
    });

    test('applies keyword prefix and suffix to output', () {
      final feature = BddFeature('Prefix Suffix Feature');
      final background = feature.background;

      const customConfig = BddConfig(
        keywords: BddKeywords(background: 'Background:'),
        keywordPrefix: BddKeywords.only(background: '--> '),
        keywordSuffix: BddKeywords.only(background: ' <--'),
      );

      final output = background.toString(customConfig);
      expect(output, '  --> Background: <--\n');
    });

    test('returns correct indentation based on config padding and spaces', () {
      final feature = BddFeature('Indentation Feature');
      final background = feature.background;
      background.given('a condition');

      const customConfig = BddConfig(
        padChar: '\t',
        indent: 1, // Single tab for spaces()
      );

      final output = background.toString(customConfig);
      expect(output, '\tBackground:\n\t\tGiven a condition\n');
    });

    test('uses custom endOfLineChar correctly', () {
      final feature = BddFeature('CRLF Feature');
      final background = feature.background;
      background.given('a condition');

      const customConfig = BddConfig(endOfLineChar: '\r\n');

      final output = background.toString(customConfig);
      expect(output, '  Background:\r\n    Given a condition\r\n');
    });
  });

  group('BddBackground Step Delegation', () {
    test('given registers step in internal framework', () {
      final feature = BddFeature('Delegation Feature');
      final background = feature.background;

      background.given('state setup');

      final internalFramework = feature.backgroundFramework!;
      expect(internalFramework.terms.length, 1);
      final term = internalFramework.terms.first;
      expect(term, isA<BddGiven>());
      expect((term as BddGiven).text, 'state setup');
    });

    test('note creates BddGiven note instance', () {
      final feature = BddFeature('Delegation Feature');
      final background = feature.background;

      background.note('important context');

      final internalFramework = feature.backgroundFramework!;
      expect(internalFramework.terms.length, 1);
      final term = internalFramework.terms.first;
      expect(term, isA<BddGiven>());
      expect((term as BddGiven).text, 'important context');
      // variation is private, but checking the output prefix/character validates it.
      expect(term.toString(const BddConfig()), '    # Important context');
    });

    test('delegated steps are included in final toString output', () {
      final feature = BddFeature('Delegation Feature');
      feature.background.given('step 1');
      feature.background.given('step 2');

      final output = feature.background.toString(const BddConfig());
      expect(output, contains('Given step 1'));
      expect(output, contains('Given step 2'));
    });
  });

  group('BddBackground Inheritance & Structure', () {
    test('initialization super constructor passes empty text to super class',
        () {
      final feature = BddFeature('Structure Feature');
      final background = feature.background;

      // Ensure the text of the background itself is empty, as it acts as a grouping block
      expect(background.text, isEmpty);
    });

    test('prefix and suffix return empty strings', () {
      final feature = BddFeature('Structure Feature');
      final background = feature.background;
      const config = BddConfig();

      expect(background.prefix(config), isEmpty);
      expect(background.suffix(config), isEmpty);
    });
  });

  group('BddBackground Runner Integration', () {
    test(
        'Background steps are executed before scenario steps using Bdd.runTest',
        () async {
      final feature = BddFeature('Background Run Test');
      final log = <String>[];

      feature.background
          .given('background setup')
          .code((_) => log.add('bg1'))
          .and('more background setup')
          .code((_) => log.add('bg2'));

      final bdd = Bdd(feature)
          .scenario('Main Flow')
          .given('initial condition')
          .code((_) => log.add('s1'))
          .when('action occurs')
          .code((_) => log.add('w1'))
          .then('outcome happens')
          .code((_) => log.add('t1'));

      bdd.testRun((_) {
        log.add('runTest_end');
      }, ConsoleReporter());

      expect(log, ['bg1', 'bg2', 's1', 'w1', 't1', 'runTest_end']);
    });
  });
}

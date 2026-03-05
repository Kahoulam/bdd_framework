import 'package:bdd_framework/bdd_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BddFeature Basic Properties', () {
    test('constructs with a title successfully', () {
      final feature = BddFeature('Login System');
      expect(feature.title, 'Login System');
      expect(feature.description, isNull);
      expect(feature.backgroundFramework, isNull);
      expect(feature.bdds, isEmpty);
      expect(feature.isNotEmpty, isTrue);
      expect(feature.isEmpty, isFalse);
    });

    test('constructs with an empty title', () {
      final feature = BddFeature('');
      expect(feature.isEmpty, isTrue);
      expect(feature.isNotEmpty, isFalse);
    });

    test('equality is based exclusively on identical title', () {
      final featureA = BddFeature('Payment Gateway');
      final featureB =
          BddFeature('Payment Gateway', description: 'Testing out payments');
      final featureC = BddFeature('User Profiles');

      expect(featureA, equals(featureB));
      expect(featureA, isNot(equals(featureC)));
      expect(featureA.hashCode, equals(featureB.hashCode));
    });
  });

  group('BddFeature Rendering (toString)', () {
    test('renders accurately without description', () {
      final feature = BddFeature('Login System');
      final output = feature.toString(const BddConfig());

      expect(output, 'Feature: Login System\n');
    });

    test('renders accurately with single-line description', () {
      final feature = BddFeature('Login System',
          description: 'Ensures users can authenticate');
      final output = feature.toString(const BddConfig());

      expect(
          output, 'Feature: Login System\n  Ensures users can authenticate\n');
    });

    test(
        'renders accurately with multi-line description and preserves lines natively',
        () {
      final feature = BddFeature(
        'Login System',
        description:
            'Ensures users can authenticate\nProvides OTP functionality\nProtects against CSRF',
      );
      final output = feature.toString(const BddConfig());

      expect(
        output,
        'Feature: Login System\n'
        '  Ensures users can authenticate\n'
        '  Provides OTP functionality\n'
        '  Protects against CSRF\n',
      );
    });

    test(
        'renders accurately with custom formatting and padding in toString config',
        () {
      final feature = BddFeature(
        'Login System',
        description: 'Description 1\nDescription 2',
      );

      const customConfig = BddConfig(
        keywords: BddKeywords(feature: '功能:'),
        prefix: BddKeywords.only(feature: '-->'),
        suffix: BddKeywords.only(feature: '<--'),
        endOfLineChar: '\r\n',
        padChar: '\t',
        indent: 1, // Single tab space indentation
      );

      final output = feature.toString(customConfig);

      expect(
        output,
        '功能: -->Login System<--\r\n'
        '\t-->Description 1\r\n' // BddFeature `join` places newline+spaces between parts, but prefix is at start, suffix is at end.
        '\tDescription 2<--\r\n',
      );
    });

    test('toString excludes Background (Background is rendered by Reporter)',
        () {
      final feature = BddFeature('Payment Checkout');
      feature.background.given('a valid credit card is stored');

      final output = feature.toString(const BddConfig());

      // Feature.toString() should only contain the Feature header, not Background
      expect(output, 'Feature: Payment Checkout\n');

      // Background is rendered independently
      final bgOutput = feature.background.toString(const BddConfig());
      expect(
        bgOutput,
        '  Background:\n'
        '    Given a valid credit card is stored\n',
      );
    });
  });

  group('BddFeature.userStory Named Constructor', () {
    test('constructs with title and User Story parts', () {
      final feature = BddFeature.userStory(
        'User Login',
        asA: 'Registered User',
        iWant: 'to log into my account',
        soThat: 'I can access my private dashboard',
      );

      expect(feature.title, 'User Login');
      expect(feature.description, isNull);
      expect(feature.isNotEmpty, isTrue);
    });

    test('renders User Story lines after Feature title', () {
      final feature = BddFeature.userStory(
        'User Login',
        asA: 'Registered User',
        iWant: 'to log into my account',
        soThat: 'I can access my private dashboard',
      );
      final output = feature.toString(const BddConfig());

      expect(
        output,
        'Feature: User Login\n'
        '  As a Registered User\n'
        '  I want to log into my account\n'
        '  So that I can access my private dashboard\n',
      );
    });

    test('equality: userStory and plain constructor with same title are equal',
        () {
      final featureA = BddFeature.userStory(
        'Payment Gateway',
        asA: 'Customer',
        iWant: 'to pay',
        soThat: 'I can complete checkout',
      );
      final featureB = BddFeature('Payment Gateway');

      expect(featureA, equals(featureB));
      expect(featureA.hashCode, equals(featureB.hashCode));
    });

    test('toString excludes Background for userStory', () {
      final feature = BddFeature.userStory(
        'Payment Checkout',
        asA: 'Customer',
        iWant: 'to checkout my cart',
        soThat: 'I can receive my order',
      );
      feature.background.given('a valid credit card is stored');

      final output = feature.toString(const BddConfig());

      expect(
        output,
        'Feature: Payment Checkout\n'
        '  As a Customer\n'
        '  I want to checkout my cart\n'
        '  So that I can receive my order\n',
      );
    });
  });

  group('BddFeature Collections', () {
    test('scenarios (bdds) can be added and duplicate instances are rejected',
        () {
      final feature = BddFeature('Checkout');
      expect(feature.bdds, isEmpty);

      final bdd =
          Bdd(feature).scenario('Simple Payment').given('An item in cart');

      feature.add(bdd.bdd);
      expect(feature.bdds.length, 1);

      // Attempting to add the exact same instance again shouldn't increase the list
      feature.add(bdd.bdd);
      expect(feature.bdds.length, 1);
    });

    test('testResults getter correctly maps all collected scenarios in feature',
        () {
      final feature = BddFeature('Dashboard');

      final bdd1 = Bdd(feature).scenario('View graph');
      final bdd2 = Bdd(feature).scenario('View stats');

      feature.add(bdd1.bdd);
      feature.add(bdd2.bdd);

      expect(feature.testResults.length, 2);
      expect(feature.testResults.first.runtimeType.toString(), 'TestResult');
    });
  });
}

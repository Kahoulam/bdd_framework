import 'package:bdd_framework/bdd_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeatureDescription (plain text)', () {
    test('formats single-line text with default config', () {
      final desc = FeatureDescription(text: 'Ensures users can authenticate');
      final output = desc.format(const BddConfig());

      expect(output, '  Ensures users can authenticate\n');
    });

    test('formats multi-line text preserving each line', () {
      final desc = FeatureDescription(
        text:
            'Ensures users can authenticate\nProvides OTP functionality\nProtects against CSRF',
      );
      final output = desc.format(const BddConfig());

      expect(
        output,
        '  Ensures users can authenticate\n'
        '  Provides OTP functionality\n'
        '  Protects against CSRF\n',
      );
    });
  });

  group('FeatureDescription.userStory', () {
    test('stores asA, iWant, soThat and text is null', () {
      final desc = FeatureDescription.userStory(
        asA: 'Registered User',
        iWant: 'to log into my account',
        soThat: 'I can access my private dashboard',
      );

      expect(desc.asA, 'Registered User');
      expect(desc.iWant, 'to log into my account');
      expect(desc.soThat, 'I can access my private dashboard');
      expect(desc.text, isNull);
    });

    test('formats with default English keywords', () {
      final desc = FeatureDescription.userStory(
        asA: 'Registered User',
        iWant: 'to log into my account',
        soThat: 'I can access my private dashboard',
      );
      final output = desc.format(const BddConfig());

      expect(
        output,
        '  As a Registered User\n'
        '  I want to log into my account\n'
        '  So that I can access my private dashboard\n',
      );
    });

    test('formats with custom i18n keywords (Chinese)', () {
      final desc = FeatureDescription.userStory(
        asA: 'Registered User',
        iWant: 'to log into my account',
        soThat: 'I can access my private dashboard',
      );

      const zhConfig = BddConfig(
        keywords: BddKeywords(
          feature: '功能:',
          asA: '作為',
          iWant: '我想要',
          soThat: '以便',
        ),
      );
      final output = desc.format(zhConfig);

      expect(
        output,
        '  作為 Registered User\n'
        '  我想要 to log into my account\n'
        '  以便 I can access my private dashboard\n',
      );
    });

    test('formats with custom indent and padChar', () {
      final desc = FeatureDescription.userStory(
        asA: 'Admin',
        iWant: 'to manage users',
        soThat: 'I can control access',
      );

      const customConfig = BddConfig(
        indent: 1,
        padChar: '\t',
        endOfLineChar: '\r\n',
      );
      final output = desc.format(customConfig);

      expect(
        output,
        '\tAs a Admin\r\n'
        '\tI want to manage users\r\n'
        '\tSo that I can control access\r\n',
      );
    });
  });
}

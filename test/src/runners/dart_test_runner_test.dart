import 'package:bdd_framework/dart_test.dart';
import 'package:test/test.dart';

void main() {
  var feature = BddFeature('Dart Test Runner');

  group('run', () {
    Bdd(feature)
        .scenario('Executes code callback')
        .given('A BDD scenario with a code callback')
        .when('The run method is invoked')
        .then('The callback is executed')
        .code((ctx) {
      // If this callback runs, the test passes.
      expect(true, isTrue);
    }).run();

    Bdd(feature)
        .scenario('Runs without callback')
        .given('A BDD scenario')
        .when('Run is invoked without a callback')
        .then('No error occurs')
        .run();
  });

  group('code steps', () {
    final log = <String>[];
    Bdd(feature)
        .scenario('Executes multiple code steps in order')
        .given('A scenario with multiple code blocks')
        .code((ctx) {
          log.add('given');
        })
        .when('Each step appends to a shared log')
        .code((ctx) {
          log.add('when');
        })
        .then('All steps ran in correct order')
        .code((ctx) {
          log.add('then');
          expect(log, ['given', 'when', 'then']);
        })
        .run();
  });

  group('example values', () {
    Bdd(feature)
        .scenario('Accesses example values in code callback')
        .given('A scenario with <color> and <count>')
        .when('The code reads from ctx.example')
        .then('The values match the current example row')
        .example(val('color', 'red'), val('count', 3))
        .example(val('color', 'blue'), val('count', 7))
        .run((ctx) {
      final color = ctx.example.val('color') as String;
      final count = ctx.example.val('count') as int;
      expect(color, isNotEmpty);
      expect(count, greaterThan(0));
      // Cross-validate: red→3, blue→7
      if (color == 'red') expect(count, 3);
      if (color == 'blue') expect(count, 7);
    });
  });

  group('table values', () {
    Bdd(feature)
        .scenario('Accesses table values in code callback')
        .given('A scenario with a data table')
        .table(
          'fruits',
          row(val('name', 'apple'), val('qty', 5)),
          row(val('name', 'banana'), val('qty', 12)),
        )
        .when('The code reads from ctx.table')
        .then('The table data is accessible by name and row index')
        .run((ctx) {
      expect(ctx.table('fruits').row(0).val('name'), 'apple');
      expect(ctx.table('fruits').row(0).val('qty'), 5);
      expect(ctx.table('fruits').row(1).val('name'), 'banana');
      expect(ctx.table('fruits').row(1).val('qty'), 12);
    });
  });
}

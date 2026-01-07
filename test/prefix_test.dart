import 'package:flutter_test/flutter_test.dart';
import 'package:units_of_measure_converter/ucum_units.dart';

void main() {
  group('UcumPrefix', () {
    test('kilo prefix has correct values', () {
      expect(UcumPrefixes.kilo.code, equals('k'));
      expect(UcumPrefixes.kilo.value, equals(1000.0));
      expect(UcumPrefixes.kilo.exponent, equals(3));
      expect(UcumPrefixes.kilo.name, equals('kilo'));
    });

    test('milli prefix has correct values', () {
      expect(UcumPrefixes.milli.code, equals('m'));
      expect(UcumPrefixes.milli.value, equals(0.001));
      expect(UcumPrefixes.milli.exponent, equals(-3));
    });

    test('micro prefix has correct values', () {
      expect(UcumPrefixes.micro.code, equals('u'));
      expect(UcumPrefixes.micro.value, equals(1e-6));
      expect(UcumPrefixes.micro.printSymbol, equals('μ'));
    });

    test('all prefixes are defined', () {
      expect(UcumPrefixes.all.length, greaterThanOrEqualTo(20));
    });

    test('prefix lookup by code works', () {
      expect(UcumPrefixes.byCode['k'], equals(UcumPrefixes.kilo));
      expect(UcumPrefixes.byCode['m'], equals(UcumPrefixes.milli));
      expect(UcumPrefixes.byCode['n'], equals(UcumPrefixes.nano));
    });

    test('binary prefixes are defined', () {
      expect(UcumPrefixes.kibi.value, equals(1024));
      expect(UcumPrefixes.mebi.value, equals(1048576));
    });
  });
}

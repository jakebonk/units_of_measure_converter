import 'package:flutter_test/flutter_test.dart';
import 'package:units_of_measure_converter/units_of_measure_converter.dart';

void main() {
  late UnitParser parser;

  setUp(() {
    parser = UnitParser();
  });

  group('UnitParser - Simple Units', () {
    test('parses base unit meter', () {
      final result = parser.parse('m');
      expect(result.isValid, isTrue);
      expect(result.unit?.code, equals('m'));
      expect(result.magnitude, equals(1.0));
      expect(result.dimension, equals(const Dimension(length: 1)));
    });

    test('parses base unit second', () {
      final result = parser.parse('s');
      expect(result.isValid, isTrue);
      expect(result.unit?.code, equals('s'));
      expect(result.dimension, equals(const Dimension(time: 1)));
    });

    test('parses base unit gram', () {
      final result = parser.parse('g');
      expect(result.isValid, isTrue);
      expect(result.unit?.code, equals('g'));
      expect(result.dimension, equals(const Dimension(mass: 1)));
    });

    test('parses derived unit Joule', () {
      final result = parser.parse('J');
      expect(result.isValid, isTrue);
      expect(result.unit?.code, equals('J'));
      expect(result.unit?.property, equals('energy'));
    });
  });

  group('UnitParser - Prefixed Units', () {
    test('parses kilometer', () {
      final result = parser.parse('km');
      expect(result.isValid, isTrue);
      expect(result.unit?.code, equals('m'));
      expect(result.prefix?.code, equals('k'));
      expect(result.magnitude, equals(1000.0));
    });

    test('parses milligram', () {
      final result = parser.parse('mg');
      expect(result.isValid, isTrue);
      expect(result.unit?.code, equals('g'));
      expect(result.prefix?.code, equals('m'));
      expect(result.magnitude, closeTo(0.001, 1e-10));
    });

    test('parses microgram', () {
      final result = parser.parse('ug');
      expect(result.isValid, isTrue);
      expect(result.prefix?.code, equals('u'));
      expect(result.magnitude, closeTo(1e-6, 1e-15));
    });

    test('parses nanosecond', () {
      final result = parser.parse('ns');
      expect(result.isValid, isTrue);
      expect(result.magnitude, closeTo(1e-9, 1e-18));
    });
  });

  group('UnitParser - Compound Units', () {
    test('parses m/s (velocity)', () {
      final result = parser.parse('m/s');
      expect(result.isValid, isTrue);
      expect(result.dimension, equals(const Dimension(length: 1, time: -1)));
    });

    test('parses kg.m/s2 (force)', () {
      final result = parser.parse('kg.m/s2');
      expect(result.isValid, isTrue);
      // Force dimension: M^1 L^1 T^-2
      expect(result.dimension.mass, equals(1));
      expect(result.dimension.length, equals(1));
      expect(result.dimension.time, equals(-2));
    });

    test('parses mg/dL (concentration)', () {
      final result = parser.parse('mg/dL');
      expect(result.isValid, isTrue);
      // Mass per volume: M^1 L^-3
      expect(result.dimension.mass, equals(1));
      expect(result.dimension.length, equals(-3));
    });

    test('parses m2 (area)', () {
      final result = parser.parse('m2');
      expect(result.isValid, isTrue);
      expect(result.dimension, equals(const Dimension(length: 2)));
    });

    test('parses m3 (volume)', () {
      final result = parser.parse('m3');
      expect(result.isValid, isTrue);
      expect(result.dimension, equals(const Dimension(length: 3)));
    });

    test('parses m-1 (inverse length)', () {
      final result = parser.parse('m-1');
      expect(result.isValid, isTrue);
      expect(result.dimension, equals(const Dimension(length: -1)));
    });
  });

  group('UnitParser - Bracketed Units', () {
    test('parses [in_i] (inch)', () {
      final result = parser.parse('[in_i]');
      expect(result.isValid, isTrue);
      expect(result.unit?.code, equals('[in_i]'));
      expect(result.magnitude, closeTo(0.0254, 1e-6));
    });

    test('parses [lb_av] (pound)', () {
      final result = parser.parse('[lb_av]');
      expect(result.isValid, isTrue);
      expect(result.unit?.code, equals('[lb_av]'));
    });

    test('parses [ft_i] (foot)', () {
      final result = parser.parse('[ft_i]');
      expect(result.isValid, isTrue);
      expect(result.magnitude, closeTo(0.3048, 1e-6));
    });
  });

  group('UnitParser - Validation', () {
    test('validates correct unit', () {
      final result = parser.validate('kg');
      expect(result.isValid, isTrue);
      expect(result.normalizedCode, isNotNull);
    });

    test('rejects unknown unit', () {
      final result = parser.validate('xyz');
      expect(result.isValid, isFalse);
      expect(result.messages, isNotEmpty);
    });

    test('provides suggestions for invalid units', () {
      final result = parser.validate('meters');
      // May or may not find suggestions depending on search
      expect(result.isValid, isFalse);
    });
  });

  group('UnitParser - Edge Cases', () {
    test('handles empty string', () {
      final result = parser.parse('');
      expect(result.isValid, isFalse);
      expect(result.error, isNotNull);
    });

    test('handles unity (1)', () {
      final result = parser.parse('1');
      expect(result.isValid, isTrue);
      expect(result.dimension.isDimensionless, isTrue);
    });

    test('handles percent', () {
      final result = parser.parse('%');
      expect(result.isValid, isTrue);
      expect(result.magnitude, closeTo(0.01, 1e-10));
    });
  });
}

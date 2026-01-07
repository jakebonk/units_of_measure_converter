import 'package:flutter_test/flutter_test.dart';
import 'package:units_of_measure_converter/ucum_units.dart';

void main() {
  late UnitConverter converter;

  setUp(() {
    converter = UnitConverter();
  });

  group('UnitConverter - Length Conversions', () {
    test('converts meters to kilometers', () {
      final result = converter.convert(1000.0, 'm', 'km');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1.0, 1e-10));
    });

    test('converts kilometers to meters', () {
      final result = converter.convert(1.0, 'km', 'm');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1000.0, 1e-10));
    });

    test('converts inches to centimeters', () {
      final result = converter.convert(1.0, '[in_i]', 'cm');
      expect(result.success, isTrue);
      expect(result.value, closeTo(2.54, 1e-6));
    });

    test('converts feet to meters', () {
      final result = converter.convert(1.0, '[ft_i]', 'm');
      expect(result.success, isTrue);
      expect(result.value, closeTo(0.3048, 1e-6));
    });

    test('converts miles to kilometers', () {
      final result = converter.convert(1.0, '[mi_i]', 'km');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1.609344, 1e-6));
    });

    test('converts centimeters to millimeters', () {
      final result = converter.convert(1.0, 'cm', 'mm');
      expect(result.success, isTrue);
      expect(result.value, closeTo(10.0, 1e-10));
    });
  });

  group('UnitConverter - Mass Conversions', () {
    test('converts kilograms to grams', () {
      final result = converter.convert(1.0, 'kg', 'g');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1000.0, 1e-10));
    });

    test('converts pounds to kilograms', () {
      final result = converter.convert(1.0, '[lb_av]', 'kg');
      expect(result.success, isTrue);
      expect(result.value, closeTo(0.45359237, 1e-6));
    });

    test('converts ounces to grams', () {
      final result = converter.convert(1.0, '[oz_av]', 'g');
      expect(result.success, isTrue);
      expect(result.value, closeTo(28.349523125, 1e-6));
    });

    test('converts milligrams to micrograms', () {
      final result = converter.convert(1.0, 'mg', 'ug');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1000.0, 1e-10));
    });
  });

  group('UnitConverter - Time Conversions', () {
    test('converts hours to minutes', () {
      final result = converter.convert(1.0, 'h', 'min');
      expect(result.success, isTrue);
      expect(result.value, closeTo(60.0, 1e-10));
    });

    test('converts days to hours', () {
      final result = converter.convert(1.0, 'd', 'h');
      expect(result.success, isTrue);
      expect(result.value, closeTo(24.0, 1e-10));
    });

    test('converts minutes to seconds', () {
      final result = converter.convert(1.0, 'min', 's');
      expect(result.success, isTrue);
      expect(result.value, closeTo(60.0, 1e-10));
    });

    test('converts milliseconds to seconds', () {
      final result = converter.convert(1000.0, 'ms', 's');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1.0, 1e-10));
    });
  });

  group('UnitConverter - Volume Conversions', () {
    test('converts liters to milliliters', () {
      final result = converter.convert(1.0, 'L', 'mL');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1000.0, 1e-10));
    });

    test('converts gallons to liters', () {
      final result = converter.convert(1.0, '[gal_us]', 'L');
      expect(result.success, isTrue);
      expect(result.value, closeTo(3.785411784, 1e-6));
    });

    test('converts cubic meters to liters', () {
      final result = converter.convert(1.0, 'm3', 'L');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1000.0, 1e-6));
    });
  });

  group('UnitConverter - Temperature Conversions', () {
    test('converts Celsius to Kelvin', () {
      final result = converter.convert(0.0, 'Cel', 'K');
      expect(result.success, isTrue);
      expect(result.value, closeTo(273.15, 1e-6));
    });

    test('converts Fahrenheit to Celsius', () {
      final result = converter.convert(32.0, '[degF]', 'Cel');
      expect(result.success, isTrue);
      expect(result.value, closeTo(0.0, 1e-6));
    });

    test('converts boiling point Fahrenheit to Celsius', () {
      final result = converter.convert(212.0, '[degF]', 'Cel');
      expect(result.success, isTrue);
      expect(result.value, closeTo(100.0, 1e-6));
    });

    test('converts body temperature Celsius to Fahrenheit', () {
      final result = converter.convert(37.0, 'Cel', '[degF]');
      expect(result.success, isTrue);
      expect(result.value, closeTo(98.6, 0.1));
    });
  });

  group('UnitConverter - Compound Units', () {
    test('converts km/h to m/s', () {
      final result = converter.convert(36.0, 'km/h', 'm/s');
      expect(result.success, isTrue);
      expect(result.value, closeTo(10.0, 1e-10));
    });

    test('converts m/s to km/h', () {
      final result = converter.convert(10.0, 'm/s', 'km/h');
      expect(result.success, isTrue);
      expect(result.value, closeTo(36.0, 1e-10));
    });

    test('converts mg/dL to g/L', () {
      final result = converter.convert(100.0, 'mg/dL', 'g/L');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1.0, 1e-10));
    });
  });

  group('UnitConverter - Pressure Conversions', () {
    test('converts bar to Pascal', () {
      final result = converter.convert(1.0, 'bar', 'Pa');
      expect(result.success, isTrue);
      expect(result.value, closeTo(100000.0, 1e-6));
    });

    test('converts atm to bar', () {
      final result = converter.convert(1.0, 'atm', 'bar');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1.01325, 1e-5));
    });

    test('converts mmHg to Pa', () {
      final result = converter.convert(1.0, 'mm[Hg]', 'Pa');
      expect(result.success, isTrue);
      expect(result.value, closeTo(133.322387415, 1e-6));
    });
  });

  group('UnitConverter - Energy Conversions', () {
    test('converts kilojoules to joules', () {
      final result = converter.convert(1.0, 'kJ', 'J');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1000.0, 1e-10));
    });

    test('converts calories to joules', () {
      final result = converter.convert(1.0, 'cal', 'J');
      expect(result.success, isTrue);
      expect(result.value, closeTo(4.184, 1e-6));
    });
  });

  group('UnitConverter - Commensurability', () {
    test('meters and kilometers are commensurable', () {
      expect(converter.areCommensurable('m', 'km'), isTrue);
    });

    test('meters and seconds are not commensurable', () {
      expect(converter.areCommensurable('m', 's'), isFalse);
    });

    test('kg and lb are commensurable', () {
      expect(converter.areCommensurable('kg', '[lb_av]'), isTrue);
    });

    test('m/s and km/h are commensurable', () {
      expect(converter.areCommensurable('m/s', 'km/h'), isTrue);
    });
  });

  group('UnitConverter - Error Handling', () {
    test('returns error for unknown source unit', () {
      final result = converter.convert(1.0, 'xyz', 'm');
      expect(result.success, isFalse);
      expect(result.message, contains('Invalid'));
    });

    test('returns error for unknown target unit', () {
      final result = converter.convert(1.0, 'm', 'xyz');
      expect(result.success, isFalse);
      expect(result.message, contains('Invalid'));
    });

    test('returns error for incompatible units', () {
      final result = converter.convert(1.0, 'm', 's');
      expect(result.success, isFalse);
      expect(result.message, contains('commensurable'));
    });
  });

  group('UnitConverter - Base Unit Conversion', () {
    test('converts km to base units', () {
      final result = converter.convertToBaseUnits(1.0, 'km');
      expect(result.value, closeTo(1000.0, 1e-10));
      expect(result.dimension, equals(const Dimension(length: 1)));
    });

    test('converts kg.m/s2 to base units', () {
      final result = converter.convertToBaseUnits(1.0, 'kg.m/s2');
      // Should be in g.m/s2 (base mass is gram)
      expect(result.dimension.mass, equals(1));
      expect(result.dimension.length, equals(1));
      expect(result.dimension.time, equals(-2));
    });
  });

  group('UnitConverter - Get Commensurable Units', () {
    test('finds commensurable units for meter', () {
      final units = converter.getCommensurableUnits('m');
      expect(units.any((u) => u.code == 'm'), isTrue);
      expect(units.any((u) => u.code == '[in_i]'), isTrue);
      expect(units.any((u) => u.code == '[ft_i]'), isTrue);
    });

    test('finds commensurable units for gram', () {
      final units = converter.getCommensurableUnits('g');
      expect(units.any((u) => u.code == 'g'), isTrue);
      expect(units.any((u) => u.code == '[lb_av]'), isTrue);
    });
  });
}

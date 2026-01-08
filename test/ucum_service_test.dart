import 'package:flutter_test/flutter_test.dart';
import 'package:units_of_measure_converter/units_of_measure_converter.dart';

void main() {
  late UcumService ucum;

  setUp(() {
    ucum = UcumService.createInstance();
  });

  group('UcumService - Singleton', () {
    test('getInstance returns same instance', () {
      final instance1 = UcumService.getInstance();
      final instance2 = UcumService.getInstance();
      expect(identical(instance1, instance2), isTrue);
    });

    test('createInstance returns new instance', () {
      final instance1 = UcumService.createInstance();
      final instance2 = UcumService.createInstance();
      expect(identical(instance1, instance2), isFalse);
    });
  });

  group('UcumService - Validation', () {
    test('validates simple unit', () {
      final result = ucum.validateUnitString('kg');
      expect(result.isValid, isTrue);
    });

    test('validates compound unit', () {
      final result = ucum.validateUnitString('mg/dL');
      expect(result.isValid, isTrue);
    });

    test('rejects invalid unit', () {
      final result = ucum.validateUnitString('invalid_unit');
      expect(result.isValid, isFalse);
    });
  });

  group('UcumService - Conversion', () {
    test('converts km to m', () {
      final result = ucum.convertUnitTo('km', 5.0, 'm');
      expect(result.success, isTrue);
      expect(result.value, closeTo(5000.0, 1e-10));
    });

    test('converts mg/dL to g/L', () {
      final result = ucum.convertUnitTo('mg/dL', 100.0, 'g/L');
      expect(result.success, isTrue);
      expect(result.value, closeTo(1.0, 1e-10));
    });

    test('handles temperature conversion', () {
      final result = ucum.convertUnitTo('Cel', 100.0, 'K');
      expect(result.success, isTrue);
      expect(result.value, closeTo(373.15, 1e-6));
    });
  });

  group('UcumService - Unit Lookup', () {
    test('gets unit by code', () {
      final unit = ucum.getUnitByCode('m');
      expect(unit, isNotNull);
      expect(unit!.name, equals('meter'));
    });

    test('returns null for unknown code', () {
      final unit = ucum.getUnitByCode('unknown');
      expect(unit, isNull);
    });

    test('searches units by name', () {
      final results = ucum.searchUnits('meter');
      expect(results, isNotEmpty);
      expect(results.any((u) => u.code == 'm'), isTrue);
    });

    test('searches units by synonym', () {
      final results = ucum.searchUnits('pounds');
      expect(results, isNotEmpty);
    });

    test('limits search results', () {
      final results = ucum.searchUnits('m', maxResults: 3);
      expect(results.length, lessThanOrEqualTo(3));
    });
  });

  group('UcumService - Commensurable Units', () {
    test('finds commensurable units for length', () {
      final units = ucum.commensurablesList('m');
      expect(units.any((u) => u.code == 'm'), isTrue);
      expect(units.any((u) => u.code == '[in_i]'), isTrue);
      expect(units.any((u) => u.code == '[ft_i]'), isTrue);
    });

    test('finds commensurable units for mass', () {
      final units = ucum.commensurablesList('kg');
      expect(units.any((u) => u.code == 'g'), isTrue);
      expect(units.any((u) => u.code == '[lb_av]'), isTrue);
    });
  });

  group('UcumService - Synonym Check', () {
    test('finds unit by synonym', () {
      final results = ucum.checkSynonyms('metre');
      expect(results.any((u) => u.code == 'm'), isTrue);
    });

    test('finds unit by exact name', () {
      final results = ucum.checkSynonyms('meter');
      expect(results.any((u) => u.code == 'm'), isTrue);
    });
  });

  group('UcumService - Units by Property', () {
    test('gets length units', () {
      final units = ucum.getUnitsByProperty('length');
      expect(units, isNotEmpty);
      expect(units.every((u) => u.property == 'length'), isTrue);
    });

    test('gets mass units', () {
      final units = ucum.getUnitsByProperty('mass');
      expect(units, isNotEmpty);
      expect(units.every((u) => u.property == 'mass'), isTrue);
    });
  });

  group('UcumService - Base Units', () {
    test('has all 7 base units', () {
      final baseUnits = ucum.getBaseUnits();
      expect(baseUnits.length, equals(7));
    });

    test('base units have correct properties', () {
      final baseUnits = ucum.getBaseUnits();
      final properties = baseUnits.map((u) => u.property).toSet();
      expect(properties.contains('length'), isTrue);
      expect(properties.contains('time'), isTrue);
      expect(properties.contains('mass'), isTrue);
      expect(properties.contains('temperature'), isTrue);
    });
  });

  group('UcumService - Prefixes', () {
    test('has all standard prefixes', () {
      final prefixes = ucum.getAllPrefixes();
      expect(prefixes.length, greaterThanOrEqualTo(20));
    });

    test('includes SI prefixes', () {
      final prefixes = ucum.getAllPrefixes();
      final codes = prefixes.map((p) => p.code).toSet();
      expect(codes.contains('k'), isTrue); // kilo
      expect(codes.contains('m'), isTrue); // milli
      expect(codes.contains('M'), isTrue); // mega
    });
  });

  group('UcumService - Parse Unit', () {
    test('parses simple unit', () {
      final parsed = ucum.parseUnit('kg');
      expect(parsed.isValid, isTrue);
      expect(parsed.unit?.code, equals('g'));
      expect(parsed.prefix?.code, equals('k'));
    });

    test('parses simple unit with bracket', () {
      final parsed = ucum.parseUnit('[kg]');
      expect(parsed.isValid, isTrue);
      expect(parsed.unit?.code, equals('g'));
      expect(parsed.prefix?.code, equals('k'));
    });

    test('parses simple unit to plural name', () {
      final parsed = ucum.parseUnit('kg');
      expect(parsed.isValid, isTrue);
      expect(parsed.getName(plural: true), equals('kilograms'));
    });

    test('parses simple unit to plural name', () {
      final parsed = ucum.parseUnit('[lb_av]');
      expect(parsed.isValid, isTrue);
      expect(parsed.getName(plural: true), equals('pounds'));
    });

    test('parses simple unit to plural name', () {
      final parsed = ucum.parseUnit('[ft_i]');
      expect(parsed.isValid, isTrue);
      expect(parsed.getName(plural: true), equals('feet'));
    });

    test('parses simple unit to plural name', () {
      final parsed = ucum.parseUnit('[ft_i]');
      expect(parsed.isValid, isTrue);
      expect(parsed.getName(plural: false), equals('foot'));
    });

    test('parses compound unit', () {
      final parsed = ucum.parseUnit('m/s');
      expect(parsed.isValid, isTrue);
      expect(parsed.dimension, equals(const Dimension(length: 1, time: -1)));
    });
  });

  group('UcumService - Custom Units', () {
    test('adds and uses custom unit', () {
      ucum.addCustomUnit(const UcumUnit(
        isBase: false,
        name: 'custom test unit',
        code: 'ctu',
        ciCode: 'CTU',
        property: 'custom',
        magnitude: 42.0,
        dimension: Dimension(),
        isMetric: true,
      ));

      final unit = ucum.getUnitByCode('ctu');
      expect(unit, isNotNull);
      expect(unit!.name, equals('custom test unit'));
      expect(unit.magnitude, equals(42.0));
    });
  });

  group('UcumService - Convert to Base Units', () {
    test('converts km to base units', () {
      final result = ucum.convertToBaseUnits('km', 1.0);
      expect(result.value, closeTo(1000.0, 1e-10));
      expect(result.dimension.length, equals(1));
    });

    test('converts Celsius to base units (Kelvin)', () {
      final result = ucum.convertToBaseUnits('Cel', 0.0);
      expect(result.value, closeTo(273.15, 1e-6));
      expect(result.isSpecial, isTrue);
    });
  });

  group('UcumService - areCommensurable', () {
    test('length units are commensurable', () {
      expect(ucum.areCommensurable('m', 'km'), isTrue);
      expect(ucum.areCommensurable('m', '[ft_i]'), isTrue);
    });

    test('different dimensions are not commensurable', () {
      expect(ucum.areCommensurable('m', 's'), isFalse);
      expect(ucum.areCommensurable('kg', 'L'), isFalse);
    });
  });
}
